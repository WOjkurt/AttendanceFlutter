import 'dart:convert';
import '../controllers/token_controller.dart';

class AuthUser {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final String token;
  final DateTime loginTime;

  AuthUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.token,
    required this.loginTime,
  });

  factory AuthUser.fromToken(String token, DateTime loginTime) {
    final payload = TokenController.decodeTokenPayload(token);

    return AuthUser(
      uid: payload[TokenController.claimNameId] ?? '',
      email: payload[TokenController.claimName] ?? '',
      fullName: '', // Not in JWT — fetched separately from GET /api/User/{id}
      role: payload[TokenController.claimRole] ?? '',
      token: token,
      loginTime: loginTime,
    );
  }
}
