import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
abstract class AttendanceStatusEvent {}

class LoadAttendanceStatus extends AttendanceStatusEvent {}

// --- States ---
abstract class AttendanceStatusState {}

class AttendanceStatusInitial extends AttendanceStatusState {}

class AttendanceStatusLoading extends AttendanceStatusState {}

class AttendanceStatusLoaded extends AttendanceStatusState {
  final String statusMessage;

  AttendanceStatusLoaded(this.statusMessage);
}

class AttendanceStatusError extends AttendanceStatusState {
  final String errorMessage;

  AttendanceStatusError(this.errorMessage);
}

// --- BLoC ---
class AttendanceStatusBloc extends Bloc<AttendanceStatusEvent, AttendanceStatusState> {
  AttendanceStatusBloc() : super(AttendanceStatusInitial()) {
    on<LoadAttendanceStatus>((event, emit) async {
      emit(AttendanceStatusLoading());
      
      try {
        // In a real scenario, you might fetch status based on a scanned log ID.
        // Simulating loading time.
        await Future.delayed(const Duration(milliseconds: 500));
        
        emit(AttendanceStatusLoaded("Your attendance has been\nsuccessfully recorded for\ntoday's class."));
      } catch (e) {
        emit(AttendanceStatusError("Failed to load attendance status."));
      }
    });
  }
}
