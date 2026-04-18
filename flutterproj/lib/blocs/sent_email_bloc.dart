import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
abstract class SentEmailEvent {}

class LoadSentEmails extends SentEmailEvent {}

// --- States ---
abstract class SentEmailState {}

class SentEmailInitial extends SentEmailState {}

class SentEmailLoading extends SentEmailState {}

class SentEmailLoaded extends SentEmailState {
  final List<String> emails;

  SentEmailLoaded(this.emails);
}

class SentEmailError extends SentEmailState {
  final String message;

  SentEmailError(this.message);
}

// --- BLoC ---
class SentEmailBloc extends Bloc<SentEmailEvent, SentEmailState> {
  SentEmailBloc() : super(SentEmailInitial()) {
    on<LoadSentEmails>((event, emit) async {
      emit(SentEmailLoading());
      
      try {
        // Simulating a network fetch delay
        await Future.delayed(const Duration(seconds: 1));
        
        // Emitting our loaded state with dummy data
        emit(SentEmailLoaded([
          "Morning Assembly & SYM"
        ]));
      } catch (e) {
        emit(SentEmailError("Failed to fetch sent emails."));
      }
    });
  }
}
