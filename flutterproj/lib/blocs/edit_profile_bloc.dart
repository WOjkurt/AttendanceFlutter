import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
abstract class EditProfileEvent {}

class UpdateProfileSubmitted extends EditProfileEvent {
  final String greeting;
  final String? profileImagePath;

  UpdateProfileSubmitted({
    required this.greeting,
    this.profileImagePath,
  });
}

// --- States ---
abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {}

class EditProfileError extends EditProfileState {
  final String message;

  EditProfileError(this.message);
}

// --- BLoC ---
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(EditProfileInitial()) {
    on<UpdateProfileSubmitted>((event, emit) async {
      emit(EditProfileLoading());
      try {
        // Simulate a network request to update profile
        await Future.delayed(const Duration(seconds: 1));
        emit(EditProfileSuccess());
      } catch (e) {
        emit(EditProfileError("Failed to update profile."));
      }
    });
  }
}
