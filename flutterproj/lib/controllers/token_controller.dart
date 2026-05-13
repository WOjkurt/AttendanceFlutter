import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized controller for JWT token storage and decoding.
///
/// All token operations (save, read, delete, decode) go through this
/// controller so that [ApiService], [AuthService], and any other service
/// share a single source of truth.
class TokenController {
  static const _tokenKey = 'auth_token';
  static const _loginTimeKey = 'login_time';
  static const _docSeriesKey = 'document_series';

  // ─── JWT claim keys (C# / ASP.NET XML-schema URLs) ──────────────────
  static const String claimNameId =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
  static const String claimName =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';
  static const String claimRole =
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

  final FlutterSecureStorage _storage;

  TokenController({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // ─── Token persistence ──────────────────────────────────────────────

  /// Saves the JWT and records the current time as login time.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(
      key: _loginTimeKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Reads the stored JWT. Returns `null` if no token is saved.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Reads the stored login time. Returns `null` if not set.
  Future<DateTime?> getLoginTime() async {
    final str = await _storage.read(key: _loginTimeKey);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  /// Removes the token, login time, and cached document series from secure storage.
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _loginTimeKey);
    await _storage.delete(key: _docSeriesKey);
  }

  // ─── Document series cache ──────────────────────────────────────────

  /// Caches the user's DocumentSeries so subsequent profile loads
  /// don't need to re-fetch the full user list.
  Future<void> saveDocumentSeries(String documentSeries) async {
    await _storage.write(key: _docSeriesKey, value: documentSeries);
  }

  /// Reads the cached DocumentSeries. Returns `null` if not cached.
  Future<String?> getDocumentSeries() async {
    return await _storage.read(key: _docSeriesKey);
  }

  // ─── Claim convenience getters ──────────────────────────────────────

  /// Returns the user ID (`nameidentifier` claim) from the stored JWT.
  Future<String?> getUserId() async {
    final payload = await getTokenPayload();
    return payload[claimNameId] as String?;
  }

  /// Returns the email (`name` claim) from the stored JWT.
  Future<String?> getEmail() async {
    final payload = await getTokenPayload();
    return payload[claimName] as String?;
  }

  /// Returns the role (`role` claim) from the stored JWT.
  Future<String?> getRole() async {
    final payload = await getTokenPayload();
    return payload[claimRole] as String?;
  }

  // ─── JWT decoding ───────────────────────────────────────────────────

  /// Decodes the payload (middle segment) of the stored JWT.
  ///
  /// Returns an empty map `{}` if:
  /// - No token is stored
  /// - The token does not have three dot-separated parts
  /// - Base64 decoding or JSON parsing fails
  Future<Map<String, dynamic>> getTokenPayload() async {
    final token = await getToken();
    if (token == null) return {};
    return decodeTokenPayload(token);
  }

  /// Decodes the payload of an arbitrary JWT string.
  ///
  /// Returns an empty map `{}` on any failure.
  static Map<String, dynamic> decodeTokenPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};

      // Base64Url decode the middle part (payload).
      String payload = parts[1];
      // Normalize base64url → base64
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 0:
          break;
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
        default:
          return {};
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded);
      if (map is Map<String, dynamic>) return map;
      return {};
    } catch (_) {
      return {};
    }
  }
}
