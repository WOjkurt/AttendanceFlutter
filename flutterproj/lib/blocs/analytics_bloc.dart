import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/analytics_result.dart';
import '../services/analytics_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AnalyticsEvent {}

/// Fired when the attendance status page opens.
/// Respects the cache — only calls the AI service if the cache is stale
/// or the underlying data hash has changed.
class LoadAnalytics extends AnalyticsEvent {
  /// The current attendance data to analyse.
  final Map<String, dynamic> attendanceData;

  LoadAnalytics(this.attendanceData);
}

/// Fired when the user taps the force-refresh button.
/// Bypasses the cache and always calls the AI service.
class RefreshAnalytics extends AnalyticsEvent {
  /// The current attendance data to analyse.
  final Map<String, dynamic> attendanceData;

  RefreshAnalytics(this.attendanceData);
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AnalyticsState {}

/// Default state before any event has been processed.
class AnalyticsInitial extends AnalyticsState {}

/// The repository is fetching or computing analytics.
class AnalyticsLoading extends AnalyticsState {}

/// Analytics are available for display.
class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsResult result;

  /// `true` when the result was served from the local cache
  /// rather than a fresh AI call.
  final bool fromCache;

  AnalyticsLoaded({required this.result, required this.fromCache});
}

/// Something went wrong while loading analytics.
class AnalyticsError extends AnalyticsState {
  final String message;

  AnalyticsError(this.message);
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsBloc({AnalyticsRepository? repository})
      : _repository = repository ?? AnalyticsRepository(),
        super(AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<RefreshAnalytics>(_onRefreshAnalytics);
  }

  // ── Event handlers ───────────────────────────────────────────────────────

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      final (:result, :fromCache) =
          await _repository.getAnalytics(event.attendanceData);
      emit(AnalyticsLoaded(result: result, fromCache: fromCache));
    } catch (e) {
      emit(AnalyticsError('Failed to load analytics: $e'));
    }
  }

  Future<void> _onRefreshAnalytics(
    RefreshAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      final (:result, :fromCache) = await _repository.getAnalytics(
        event.attendanceData,
        forceRefresh: true,
      );
      emit(AnalyticsLoaded(result: result, fromCache: fromCache));
    } catch (e) {
      emit(AnalyticsError('Failed to refresh analytics: $e'));
    }
  }
}
