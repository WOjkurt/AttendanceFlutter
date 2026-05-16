import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/attendance_student_service.dart';
import '../controllers/token_controller.dart';
import '../models/auth_user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user.uid];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final AttendanceStudentService _attendanceService;
  final TokenController _tokenController;
  Timer? _sessionTimer;

  AuthBloc({
    AuthService? authService,
    AttendanceStudentService? attendanceService,
    TokenController? tokenController,
  })  : _authService = authService ?? AuthService(),
        _attendanceService = attendanceService ?? AttendanceStudentService(),
        _tokenController = tokenController ?? TokenController(),
        super(const AuthInitial()) {
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    return super.close();
  }

  // Handlers
  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _authService.checkAuthStatus();

    if (user != null) {
      final expirationTime = user.loginTime.add(const Duration(hours: 1));
      if (DateTime.now().isAfter(expirationTime)) {
        await _authService.signOut();
        emit(const AuthUnauthenticated());
        return;
      }

      _setSessionTimer(user);

      // Cache DS if not already stored (e.g. returning user, app restart).
      await _tryCacheStudentDocumentSeries();

      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.loginWithEmail(
        email: event.email,
        password: event.password,
      );
      _setSessionTimer(user);

      // Cache DS right after login.
      await _tryCacheStudentDocumentSeries();

      emit(AuthAuthenticated(user));
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      debugPrint('LOGIN ERROR RAW: $e');
      emit(AuthError(message));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      _sessionTimer?.cancel();
      await _authService.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(const AuthError('Failed to sign out. Please try again.'));
    }
  }

  /// Attempts to fetch and cache the student's DocumentSeries from
  /// the attendance endpoint. Skips silently if already cached or
  /// if the student has no attendance records yet.
  Future<void> _tryCacheStudentDocumentSeries() async {
    try {
      final existing = await _tokenController.getDocumentSeries();
      if (existing != null) return; // already cached, nothing to do

      final ds = await _attendanceService.fetchStudentDocumentSeries();
      if (ds != null) {
        await _tokenController.saveDocumentSeries(ds);
        if (kDebugMode) debugPrint('Student DocumentSeries cached: $ds');
      } else {
        if (kDebugMode) debugPrint('No attendance records yet — DS not cached.');
      }
    } catch (e) {
      // DS caching failing must never block the auth flow.
      if (kDebugMode) debugPrint('Could not cache student DS: $e');
    }
  }

  void _setSessionTimer(AuthUser user) {
    _sessionTimer?.cancel();
    final expirationTime = user.loginTime.add(const Duration(hours: 1));
    final durationUntilExpiration = expirationTime.difference(DateTime.now());

    if (durationUntilExpiration.isNegative) {
      add(const LogoutRequested());
    } else {
      _sessionTimer = Timer(durationUntilExpiration, () {
        add(const LogoutRequested());
      });
    }
  }
}