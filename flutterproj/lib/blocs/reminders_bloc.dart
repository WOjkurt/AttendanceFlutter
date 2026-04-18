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

// --- Hardcoded Example Data ---
final Map<String, List<ClassSchedule>> _scheduleData = {
  'M': [
    ClassSchedule(
      title: 'Morning Assembly & SYM',
      time: '7:30 AM - 9:00 AM',
      location: 'College Building',
    ),
    ClassSchedule(
      title: 'IT 317A: Information Assurance',
      time: '11:00 AM - 1:00 PM',
      location: 'Mechatronics Laboratory',
    ),
  ],
  'T': [
    ClassSchedule(
      title: 'IT 319A: Integrative Programming',
      time: '7:30 AM - 9:00 AM',
      location: 'Mechatronics Laboratory',
    ),
    ClassSchedule(
      title: 'CAP 101: Capstone 1',
      time: '1:00 PM - 4:00 PM',
      location: 'Mechatronics Laboratory',
    ),
    ClassSchedule(
      title: 'ITFE 302A: IT Free Elective 2',
      time: '4:00 PM - 5:30 PM',
      location: 'Mechatronics Laboratory',
    ),
  ],
  'W': [
    ClassSchedule(
      title: 'IT 318A: System Architecture',
      time: '9:00 AM - 10:30 AM',
      location: 'Mechatronics Laboratory',
    ),
    ClassSchedule(
      title: 'Social Service Session (SSS)',
      time: '11:00 AM - 1:00 PM',
      location: 'Audio Visual Room (AVR)',
    ),
  ],
  'TH': [
    ClassSchedule(
      title: 'IT 319A: Integrative Programming',
      time: '7:30 AM - 9:00 AM',
      location: 'Mechatronics Laboratory',
    ),
    ClassSchedule(
      title: 'IT 317A: Information Assurance',
      time: '11:00 AM - 1:00 PM',
      location: 'Mechatronics Laboratory',
    ),
  ],
  'F': [
    ClassSchedule(
      title: 'IT 318A: System Architecture',
      time: '9:00 AM - 10:30 AM',
      location: 'Room 202',
    ),
    ClassSchedule(
      title: 'CAP 101: Capstone 1',
      time: '1:00 PM - 4:00 PM',
      location: 'Mechatronics Laboratory',
    ),
    ClassSchedule(
      title: 'ITFE 302A: IT Free Elective 2',
      time: '4:00 PM - 5:30 PM',
      location: 'Mechatronics Laboratory',
    ),
  ],
  'S': [
    ClassSchedule(
      title: 'ITFE 301A: Web Applications Dev',
      time: '10:00 AM - 1:00 PM',
      location: 'Mechatronics Laboratory',
    ),
  ],
};

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
