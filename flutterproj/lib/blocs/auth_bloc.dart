import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/auth_service.dart';
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

/// Not yet determined — used during startup check.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An async operation is in progress (login / logout).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is signed in.
class AuthAuthenticated extends AuthState {
  final AuthUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user.uid];
}

/// User is signed out.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An error occurred during login.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC 
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  Timer? _sessionTimer;

  AuthBloc({AuthService? authService})
      : _authService = authService ?? AuthService(),
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

  //Handlers
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
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Clean up the Exception string for the UI
      final message = e.toString().replaceAll('Exception: ', '');
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
