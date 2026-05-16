import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/student_model.dart';
import '../models/user_model.dart';
import '../services/student_service.dart';
import '../controllers/token_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Events ─────────────────────────────────────────────────────────────────

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateDisplayName extends ProfileEvent {
  final String newName;

  const UpdateDisplayName(this.newName);

  @override
  List<Object?> get props => [newName];
}

// ─── States ──────────────────────────────────────────────────────────────────

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
  final Student? student;

  /// UserModel is kept nullable for forward-compatibility (e.g. when the
  /// backend exposes a student-accessible user endpoint in the future).
  final UserModel? user;
  final String email;
  final String documentSeries;
  final String displayName;

  const ProfileLoaded({
    this.student,
    this.user,
    required this.email,
    required this.documentSeries,
    this.displayName = '',
  });

  @override
  List<Object?> get props => [student, user, email, documentSeries, displayName];
}

class ProfileError extends ProfileState {
  final String message;
  final bool isColdStart;

  const ProfileError(this.message, {this.isColdStart = false});

  @override
  List<Object?> get props => [message, isColdStart];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final StudentService _studentService;
  final TokenController _tokenController;

  ProfileBloc({
    StudentService? studentService,
    TokenController? tokenController,
  }) : _studentService = studentService ?? StudentService(),
       _tokenController = tokenController ?? TokenController(),
       super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateDisplayName>(_onUpdateDisplayName);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // Step 1: Read email from JWT — always available, no API call needed.
      final email = await _tokenController.getEmail();
      if (email == null || email.isEmpty) {
        throw Exception('No email found in token. Please log in again.');
      }

      // Step 2: Fetch student record using the new endpoint
      Student? student;
      try {
        student = await _studentService.getCurrentStudent();
      } catch (e) {
        final msg = e.toString();
        // Surface cold-start errors explicitly; swallow 403s gracefully.
        if (msg.contains('503') ||
            msg.contains('cold') ||
            msg.contains('waking')) {
          rethrow;
        }
      }

      // Step 3: Try to read DocumentSeries from cache if student fetch failed
      String? documentSeries = student?.documentSeries;
      if (documentSeries == null || documentSeries.isEmpty) {
        documentSeries = await _tokenController.getDocumentSeries();
      }
      if (documentSeries == null || documentSeries.isEmpty) {
        final payload = await _tokenController.getTokenPayload();
        documentSeries = payload['Document Series'] as String? ?? '';
      }

      final prefs = await SharedPreferences.getInstance();
      final displayName = prefs.getString('display_name') ?? '';

      emit(
        ProfileLoaded(
          student: student,
          user: null, // GET /api/User is admin-only
          email: email,
          documentSeries: documentSeries,
          displayName: displayName,
        ),
      );
    } catch (e) {
      final message = e
          .toString()
          .replaceAll('ApiException: ', '')
          .replaceAll('Exception: ', '');

      final isColdStart =
          message.contains('503') ||
          message.contains('cold') ||
          message.contains('waking');

      emit(ProfileError(message, isColdStart: isColdStart));
    }
  }

  Future<void> _onUpdateDisplayName(
    UpdateDisplayName event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('display_name', event.newName);
      emit(
        ProfileLoaded(
          student: currentState.student,
          user: currentState.user,
          email: currentState.email,
          documentSeries: currentState.documentSeries,
          displayName: event.newName,
        ),
      );
    }
  }
}
