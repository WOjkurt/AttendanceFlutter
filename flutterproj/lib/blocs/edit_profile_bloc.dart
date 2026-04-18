import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
abstract class EditProfileEvent {}

class UpdateProfileSubmitted extends EditProfileEvent {
  // We don't necessarily need strong typing here since we just pass the profile back in the UI, 
  // but let's simulate passing data to an API
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;

  UpdateProfileSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
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
