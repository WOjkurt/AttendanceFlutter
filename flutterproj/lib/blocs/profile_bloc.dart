import 'package:flutter_bloc/flutter_bloc.dart';
import '../Pages/profile_page.dart';

// --- Events ---
abstract class ProfileEvent {}

class LoadProfileData extends ProfileEvent {}

class UpdateProfileData extends ProfileEvent {
  final UserProfile updatedProfile;

  UpdateProfileData(this.updatedProfile);
}

class LogoutRequested extends ProfileEvent {}

// --- States ---
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;

  ProfileLoaded(this.userProfile);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

// --- BLoC ---
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfileData>((event, emit) async {
      emit(ProfileLoading());

      try {
        // Simulate a network delay
        await Future.delayed(const Duration(milliseconds: 800));

        // Use the exact data from the design mockup
        final dummyData = UserProfile(
          name: "Kurt Wojtyle Rizal",
          schoolId: "23017245",
          courseAndYear: "Bachelor of Science in Information Technology | 3",
          schoolEmail: "kurtwojtyle.rizal@dbto-cebu.edu.ph",
          phoneNumber: "0913 657 86538",
          homeAddress: "Purok Nangka, Inoburan Naga Cebu, 6000",
          profileImageUrl: "https://i.pravatar.cc/300", // Placeholder since we don't have the real asset
        );

        emit(ProfileLoaded(dummyData));
      } catch (e) {
        emit(ProfileError("Failed to fetch profile data."));
      }
    });

    on<LogoutRequested>((event, emit) async {
      // In a real app, this would clear tokens, etc.
      emit(ProfileInitial()); 
    });

    on<UpdateProfileData>((event, emit) {
      if (state is ProfileLoaded) {
        emit(ProfileLoaded(event.updatedProfile));
      }
    });
  }
}
