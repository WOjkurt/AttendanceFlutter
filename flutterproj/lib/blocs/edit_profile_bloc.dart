import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// --- Events ---

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

class UpdateProfileSubmitted extends EditProfileEvent {
  final String greeting;
  final String? profileImagePath;

  const UpdateProfileSubmitted({
    required this.greeting,
    this.profileImagePath,
  });

  @override
  List<Object?> get props => [greeting, profileImagePath];
}

// --- States ---

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

class EditProfileSuccess extends EditProfileState {
  const EditProfileSuccess();
}

class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---

/// Profile editing.
///
/// NOTE: The backend does not currently expose a `PUT /api/User` endpoint,
/// so profile editing is not yet functional.
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(const EditProfileInitial()) {
    on<UpdateProfileSubmitted>((event, emit) async {
      emit(const EditProfileLoading());
      try {
        // TODO: Replace with real API call once PUT /api/User is available.
        // Example:
        //   await _userService.updateUser(userId, { ... });
        //   emit(const EditProfileSuccess());
        emit(const EditProfileError(
          'Profile editing is not yet available.',
        ));
      } catch (e) {
        emit(const EditProfileError('Failed to update profile.'));
      }
    });
  }
}
