import '../controllers/token_controller.dart';
import '../models/auth_user.dart';
import 'api_service.dart';

class AuthService extends ApiService {
  final TokenController _tokenController = TokenController();

  Future<AuthUser?> checkAuthStatus() async {
    final token = await _tokenController.getToken();
    final loginTime = await _tokenController.getLoginTime();

    if (token != null && loginTime != null) {
      try {
        final payload = TokenController.decodeTokenPayload(token);
        return AuthUser(
          uid: payload[TokenController.claimNameId] ?? '',
          email: payload[TokenController.claimName] ?? '',
          fullName: '', // Not in JWT — fetched separately from GET /api/User/{id}
          role: payload[TokenController.claimRole] ?? '',
          token: token,
          loginTime: loginTime,
        );
      } catch (e) {
        await signOut();
        return null;
      }
    }
    return null;
  }

  Future<AuthUser> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final data = await post(
        '/LogIn',
        body: {
          'email': email.trim(),
          'password': password,
        },
        requiresAuth: false,
      );

      final isSuccess = data['isSuccess'] as bool;
      final token = data['token'] as String;
      final detail = data['detail'] as String;

      if (!isSuccess) {
        throw Exception(detail);
      }

      // Persist the token via TokenController.
      await _tokenController.saveToken(token);

      // Decode the JWT payload to extract user info.
      final payload = await _tokenController.getTokenPayload();

      return AuthUser(
        uid: payload[TokenController.claimNameId] ?? '',
        email: payload[TokenController.claimName] ?? '',
        fullName: '', // Not in JWT — fetched separately from GET /api/User/{id}
        role: payload[TokenController.claimRole] ?? '',
        token: token,
        loginTime: DateTime.now(),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        throw Exception('Incorrect email or password.');
      }
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _tokenController.clearToken();
  }
}
