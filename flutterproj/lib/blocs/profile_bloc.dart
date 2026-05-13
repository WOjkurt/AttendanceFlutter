import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/student_model.dart';
import '../models/user_model.dart';
import '../services/student_service.dart';
import '../services/user_service.dart';
import '../controllers/token_controller.dart';


abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}


abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Student student;
  final UserModel user;

  const ProfileLoaded({required this.student, required this.user});

  @override
  List<Object?> get props => [student, user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final StudentService _studentService;
  final UserService _userService;
  final TokenController _tokenController;

  ProfileBloc({
    StudentService? studentService,
    UserService? userService,
    TokenController? tokenController,
  })  : _studentService = studentService ?? StudentService(),
        _userService = userService ?? UserService(),
        _tokenController = tokenController ?? TokenController(),
        super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // Step 1: get email from JWT
      final email = await _tokenController.getEmail();
      if (email == null || email.isEmpty) {
        throw Exception('No email found in token.');
      }

      // Step 2: check cached DocumentSeries first
      final cachedDocSeries = await _tokenController.getDocumentSeries();
      if (cachedDocSeries != null) {
        final student = await _studentService
            .getStudentByDocumentSeries(cachedDocSeries);
        final user = await _userService.getUserByEmail(email);
        if (student != null && user != null) {
          emit(ProfileLoaded(student: student, user: user));
          return;
        }
      }

      // Step 3: find User by email (no cache hit)
      final user = await _userService.getUserByEmail(email);
      if (user == null) throw Exception('User not found.');

      // Step 4: cache DocumentSeries for next time
      await _tokenController.saveDocumentSeries(user.documentSeries);

      // Step 5: find Student by DocumentSeries
      final student = await _studentService
          .getStudentByDocumentSeries(user.documentSeries);
      if (student == null) throw Exception('Student record not found.');

      emit(ProfileLoaded(student: student, user: user));
    } catch (e) {
      final message = e
          .toString()
          .replaceAll('ApiException: ', '')
          .replaceAll('Exception: ', '');
      emit(ProfileError(message));
    }
  }
}
