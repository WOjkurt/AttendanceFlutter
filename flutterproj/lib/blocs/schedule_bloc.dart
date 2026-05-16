import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';



abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class LoadSchedules extends ScheduleEvent {
  const LoadSchedules();
}

class LoadSchedule extends ScheduleEvent {
  const LoadSchedule();
}


abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleLoaded extends ScheduleState {
  final List<Schedule> schedules;

  const ScheduleLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class DayScheduleLoaded extends ScheduleState {
  final List<DaySchedule> schedules;

  const DayScheduleLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class ScheduleError extends ScheduleState {
  final String message;
  final bool isColdStart;

  const ScheduleError(this.message, {this.isColdStart = false});

  @override
  List<Object?> get props => [message, isColdStart];
}

// BLoC 

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleService _scheduleService;

  ScheduleBloc({ScheduleService? scheduleService})
      : _scheduleService = scheduleService ?? ScheduleService(),
        super(const ScheduleInitial()) {
    on<LoadSchedules>(_onLoadSchedules);
    on<LoadSchedule>(_onLoadSchedule);
  }

  Future<void> _onLoadSchedules(LoadSchedules event, Emitter<ScheduleState> emit) async {
    emit(const ScheduleLoading());
    try {
      final schedules = await _scheduleService.getAllSchedules();
      emit(ScheduleLoaded(schedules));
    } catch (e) {
      final message = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
      emit(ScheduleError(message));
    }
  }

  Future<void> _onLoadSchedule(LoadSchedule event, Emitter<ScheduleState> emit) async {
    emit(const ScheduleLoading());
    try {
      final schedules = await _scheduleService.getCurrentDaySchedule();
      emit(DayScheduleLoaded(schedules));
    } catch (e) {
      final message = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
      final isColdStart = message.contains('503') || message.contains('cold') || message.contains('waking');
      emit(ScheduleError(message, isColdStart: isColdStart));
    }
  }
}
