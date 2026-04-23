import 'package:flutter_bloc/flutter_bloc.dart';

// --- Model ---
class ClassSchedule {
  final String title;
  final String time;
  final String location;

  ClassSchedule({
    required this.title,
    required this.time,
    required this.location,
  });
}

// --- Events ---
abstract class RemindersEvent {}

class SelectDay extends RemindersEvent {
  final String day;
  SelectDay(this.day);
}

// --- States ---
class RemindersState {
  final String selectedDay;
  final List<ClassSchedule> classesForDay;

  RemindersState({
    required this.selectedDay,
    required this.classesForDay,
  });

  RemindersState copyWith({
    String? selectedDay,
    List<ClassSchedule>? classesForDay,
  }) {
    return RemindersState(
      selectedDay: selectedDay ?? this.selectedDay,
      classesForDay: classesForDay ?? this.classesForDay,
    );
  }
}

// --- Data Store ---
// Currently empty. The AI service / Backend integration will populate this map
// with data fetched from the endpoint.
final Map<String, List<ClassSchedule>> _scheduleData = {};

// --- BLoC ---
class RemindersBloc extends Bloc<RemindersEvent, RemindersState> {
  RemindersBloc() : super(RemindersState(selectedDay: 'M', classesForDay: _scheduleData['M'] ?? [])) {
    on<SelectDay>((event, emit) {
      final selectedClasses = _scheduleData[event.day] ?? [];
      emit(state.copyWith(
        selectedDay: event.day,
        classesForDay: selectedClasses,
      ));
    });
  }
}
