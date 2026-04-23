import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired on app startup to check if a user is already signed in.
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

/// Fired when the user submits the registration form.
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const RegisterRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Fired when the user submits the login form.
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Fired when the logout button is pressed (from any page).
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Not yet determined — used during startup check.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An async operation is in progress (login / register / logout).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is signed in.
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user.uid];
}

/// User is signed out.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An error occurred during registration or login.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  Timer? _sessionTimer;

  AuthBloc({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const AuthInitial()) {
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<RegisterRequested>(_onRegisterRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    return super.close();
  }

  // ── Handlers ──────────────────────────────────────────────────────

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authService.currentUser;
    if (user != null) {
      final lastSignIn = user.metadata.lastSignInTime;
      if (lastSignIn != null) {
        final expirationTime = lastSignIn.add(const Duration(hours: 1));
        if (DateTime.now().isAfter(expirationTime)) {
          await _authService.signOut();
          emit(const AuthUnauthenticated());
          return;
        }
      }
      _setSessionTimer(user);
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.register(
        email: event.email,
        password: event.password,
      );
      _setSessionTimer(user);
      emit(AuthAuthenticated(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred. Please try again.'));
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
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred. Please try again.'));
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

  // ── Helpers ───────────────────────────────────────────────────────

  void _setSessionTimer(User user) {
    _sessionTimer?.cancel();
    final lastSignIn = user.metadata.lastSignInTime;
    
    if (lastSignIn != null) {
      final expirationTime = lastSignIn.add(const Duration(hours: 1));
      final durationUntilExpiration = expirationTime.difference(DateTime.now());

      if (durationUntilExpiration.isNegative) {
        add(const LogoutRequested());
      } else {
        _sessionTimer = Timer(durationUntilExpiration, () {
          add(const LogoutRequested());
        });
      }
    } else {
      _sessionTimer = Timer(const Duration(hours: 1), () {
        add(const LogoutRequested());
      });
    }
  }

  /// Converts Firebase error codes into user-friendly messages.
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'That email is already registered. Try logging in instead.';
      case 'invalid-email':
        return 'Invalid email address. Use your school email (e.g. name@dbtc-cebu.edu.ph).';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled. Contact your administrator.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
