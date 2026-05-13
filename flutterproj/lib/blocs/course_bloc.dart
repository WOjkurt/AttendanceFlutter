import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';



abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourses extends CourseEvent {
  const LoadCourses();
}


abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {
  const CourseInitial();
}

class CourseLoading extends CourseState {
  const CourseLoading();
}

class CourseLoaded extends CourseState {
  final List<Course> courses;

  const CourseLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class CourseError extends CourseState {
  final String message;

  const CourseError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseService _courseService;

  CourseBloc({CourseService? courseService})
      : _courseService = courseService ?? CourseService(),
        super(const CourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
  }

  Future<void> _onLoadCourses(LoadCourses event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());
    try {
      final courses = await _courseService.getAllCourses();
      emit(CourseLoaded(courses));
    } catch (e) {
      final message = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
      emit(CourseError(message));
    }
  }
}
