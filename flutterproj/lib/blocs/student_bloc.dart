import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';


abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudents extends StudentEvent {
  const LoadStudents();
}

class LoadStudentById extends StudentEvent {
  final String id;

  const LoadStudentById(this.id);

  @override
  List<Object?> get props => [id];
}


abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {
  const StudentInitial();
}

class StudentLoading extends StudentState {
  const StudentLoading();
}

class StudentLoaded extends StudentState {
  final List<Student> students;

  const StudentLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

class StudentDetailLoaded extends StudentState {
  final Student student;

  const StudentDetailLoaded(this.student);

  @override
  List<Object?> get props => [student];
}

class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC 

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentService _studentService;

  StudentBloc({StudentService? studentService})
      : _studentService = studentService ?? StudentService(),
        super(const StudentInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<LoadStudentById>(_onLoadStudentById);
  }

  Future<void> _onLoadStudents(LoadStudents event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    try {
      final students = await _studentService.getStudents();
      emit(StudentLoaded(students));
    } catch (e) {
      final message = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
      emit(StudentError(message));
    }
  }

  Future<void> _onLoadStudentById(LoadStudentById event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    try {
      final student = await _studentService.getStudentById(event.id);
      emit(StudentDetailLoaded(student));
    } catch (e) {
      final message = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
      emit(StudentError(message));
    }
  }
}
