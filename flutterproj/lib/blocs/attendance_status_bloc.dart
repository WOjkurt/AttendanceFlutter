import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
abstract class AttendanceStatusEvent {}

class LoadAttendanceStatus extends AttendanceStatusEvent {}

// --- States ---
abstract class AttendanceStatusState {}

class AttendanceStatusInitial extends AttendanceStatusState {}

class AttendanceStatusLoading extends AttendanceStatusState {}

class AttendanceStatusLoaded extends AttendanceStatusState {
  final int? totalPresents;
  final int? totalAbsences;
  final int? totalLates;
  final String? meritStatus;
  final String statusMessage;

  AttendanceStatusLoaded({
    this.totalPresents,
    this.totalAbsences,
    this.totalLates,
    this.meritStatus,
    required this.statusMessage,
  });
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
        // Simulating loading time for live data.
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Currently no data received. AI service will populate these later.
        emit(AttendanceStatusLoaded(
          totalPresents: null,
          totalAbsences: null,
          totalLates: null,
          meritStatus: null,
          statusMessage: "Your attendance summary will appear here once data is received from the AI service.",
        ));
      } catch (e) {
        emit(AttendanceStatusError("Failed to load attendance status."));
      }
    });
  }
}
