import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

// --- Events ---

abstract class RemindersEvent extends Equatable {
  const RemindersEvent();

  @override
  List<Object?> get props => [];
}

class LoadReminders extends RemindersEvent {
  const LoadReminders();
}

// --- States ---

abstract class RemindersState extends Equatable {
  const RemindersState();

  @override
  List<Object?> get props => [];
}

class RemindersInitial extends RemindersState {
  const RemindersInitial();
}

class RemindersLoading extends RemindersState {
  const RemindersLoading();
}

class RemindersLoaded extends RemindersState {
  final Map<String, List<Schedule>> schedulesByDay;

  const RemindersLoaded(this.schedulesByDay);

  @override
  List<Object?> get props => [schedulesByDay];
}

class RemindersError extends RemindersState {
  final String message;

  const RemindersError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---

class RemindersBloc extends Bloc<RemindersEvent, RemindersState> {
  final ScheduleService _scheduleService;

  RemindersBloc({ScheduleService? scheduleService})
      : _scheduleService = scheduleService ?? ScheduleService(),
        super(const RemindersInitial()) {
    on<LoadReminders>(_onLoadReminders);
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<RemindersState> emit,
  ) async {
    emit(const RemindersLoading());
    try {
      final schedules = await _scheduleService.getAllSchedules();

      // Group schedules by dayName
      final grouped = <String, List<Schedule>>{};
      for (final schedule in schedules) {
        final day = schedule.dayName;
        grouped.putIfAbsent(day, () => []).add(schedule);
      }

      // Sort each day's schedules by start time
      for (final list in grouped.values) {
        list.sort((a, b) => a.startTime.compareTo(b.startTime));
      }

      emit(RemindersLoaded(grouped));
    } catch (e) {
      final message = e
          .toString()
          .replaceAll('ApiException: ', '')
          .replaceAll('Exception: ', '');
      emit(RemindersError(message));
    }
  }
}
