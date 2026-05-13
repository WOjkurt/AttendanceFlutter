import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/attendance_student_model.dart';
import '../services/attendance_student_service.dart';


abstract class AttendanceStudentEvent extends Equatable {
  const AttendanceStudentEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendanceStudent extends AttendanceStudentEvent {
  const LoadAttendanceStudent();
}


abstract class AttendanceStudentState extends Equatable {
  const AttendanceStudentState();

  @override
  List<Object?> get props => [];
}

class AttendanceStudentInitial extends AttendanceStudentState {
  const AttendanceStudentInitial();
}

class AttendanceStudentLoading extends AttendanceStudentState {
  const AttendanceStudentLoading();
}

class AttendanceStudentLoaded extends AttendanceStudentState {
  final List<AttendanceStudent> records;

  const AttendanceStudentLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class AttendanceStudentError extends AttendanceStudentState {
  final String message;

  const AttendanceStudentError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC 

class AttendanceStudentBloc extends Bloc<AttendanceStudentEvent, AttendanceStudentState> {
  final AttendanceStudentService _attendanceStudentService;

  AttendanceStudentBloc({AttendanceStudentService? attendanceStudentService})
      : _attendanceStudentService = attendanceStudentService ?? AttendanceStudentService(),
        super(const AttendanceStudentInitial()) {
    on<LoadAttendanceStudent>(_onLoadAttendanceStudent);
  }

  Future<void> _onLoadAttendanceStudent(LoadAttendanceStudent event, Emitter<AttendanceStudentState> emit) async {
    emit(const AttendanceStudentLoading());
    try {
      final records = await _attendanceStudentService.getAttendanceByStudent();
      emit(AttendanceStudentLoaded(records));
    } catch (e) {
      final message = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
      emit(AttendanceStudentError(message));
    }
  }
}
