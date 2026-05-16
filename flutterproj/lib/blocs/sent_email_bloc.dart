import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// --- Events ---

abstract class SentEmailEvent extends Equatable {
  const SentEmailEvent();

  @override
  List<Object?> get props => [];
}

class LoadSentEmails extends SentEmailEvent {
  const LoadSentEmails();
}

// --- States ---

abstract class SentEmailState extends Equatable {
  const SentEmailState();

  @override
  List<Object?> get props => [];
}

class SentEmailInitial extends SentEmailState {
  const SentEmailInitial();
}

class SentEmailLoading extends SentEmailState {
  const SentEmailLoading();
}

class SentEmailLoaded extends SentEmailState {
  final List<String> emails;

  const SentEmailLoaded(this.emails);

  @override
  List<Object?> get props => [emails];
}

class SentEmailError extends SentEmailState {
  final String message;

  const SentEmailError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---

/// Sent email history.
///
/// NOTE: There is no backend email endpoint yet. This BLoC emits an error
/// state until a real email service is integrated.
class SentEmailBloc extends Bloc<SentEmailEvent, SentEmailState> {
  SentEmailBloc() : super(const SentEmailInitial()) {
    on<LoadSentEmails>((event, emit) async {
      emit(const SentEmailLoading());

      try {
        // TODO: Replace with real email service call when endpoint is ready.
        // Example:
        //   final emails = await _emailService.getSentEmails();
        //   emit(SentEmailLoaded(emails));
        emit(const SentEmailError('Email feature is not yet available.'));
      } catch (e) {
        emit(const SentEmailError('Failed to fetch sent emails.'));
      }
    });
  }
}
