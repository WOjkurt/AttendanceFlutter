import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/attendance_student_model.dart';
import '../models/enums/att_status.dart';

// --- Events ---

abstract class AttendanceStatusEvent extends Equatable {
  const AttendanceStatusEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendanceStatus extends AttendanceStatusEvent {
  /// Compute statistics from already-loaded attendance records.
  final List<AttendanceStudent> records;

  const LoadAttendanceStatus(this.records);

  @override
  List<Object?> get props => [records];
}

// --- States ---

abstract class AttendanceStatusState extends Equatable {
  const AttendanceStatusState();

  @override
  List<Object?> get props => [];
}

class AttendanceStatusInitial extends AttendanceStatusState {
  const AttendanceStatusInitial();
}

class AttendanceStatusLoading extends AttendanceStatusState {
  const AttendanceStatusLoading();
}

class AttendanceStatusLoaded extends AttendanceStatusState {
  final int totalPresents;
  final int totalAbsences;
  final int totalLates;
  final int totalRecords;
  final String meritStatus;
  final String statusMessage;

  const AttendanceStatusLoaded({
    required this.totalPresents,
    required this.totalAbsences,
    required this.totalLates,
    required this.totalRecords,
    required this.meritStatus,
    required this.statusMessage,
  });

  @override
  List<Object?> get props => [
        totalPresents,
        totalAbsences,
        totalLates,
        totalRecords,
        meritStatus,
        statusMessage,
      ];
}

class AttendanceStatusError extends AttendanceStatusState {
  final String errorMessage;

  const AttendanceStatusError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// --- BLoC ---

class AttendanceStatusBloc
    extends Bloc<AttendanceStatusEvent, AttendanceStatusState> {
  AttendanceStatusBloc() : super(const AttendanceStatusInitial()) {
    on<LoadAttendanceStatus>((event, emit) async {
      emit(const AttendanceStatusLoading());

      try {
        final records = event.records;
        final totalPresents = records
            .where((r) => r.studentAttendanceStatus == AttStatus.present)
            .length;
        final totalAbsences = records
            .where((r) => r.studentAttendanceStatus == AttStatus.absent)
            .length;
        final totalLates = records
            .where((r) => r.studentAttendanceStatus == AttStatus.late)
            .length;

        final total = records.length;
        final rate = total > 0 ? (totalPresents / total * 100).round() : 0;

        String meritStatus;
        if (rate >= 90) {
          meritStatus = 'Excellent';
        } else if (rate >= 75) {
          meritStatus = 'Good';
        } else if (rate >= 60) {
          meritStatus = 'Fair';
        } else {
          meritStatus = 'Needs Improvement';
        }

        final statusMessage = total > 0
            ? 'Attendance rate: $rate% ($totalPresents present out of $total records)'
            : 'No attendance records found yet.';

        emit(AttendanceStatusLoaded(
          totalPresents: totalPresents,
          totalAbsences: totalAbsences,
          totalLates: totalLates,
          totalRecords: total,
          meritStatus: meritStatus,
          statusMessage: statusMessage,
        ));
      } catch (e) {
        emit(const AttendanceStatusError(
            'Failed to compute attendance status.'));
      }
    });
  }
}
