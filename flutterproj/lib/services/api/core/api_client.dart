import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_exception.dart';

/// Low-level HTTP wrapper shared by every service in this API layer.
///
/// It handles:
/// - Attaching a default [Authorization] header from [apiKey].
/// - Enforcing the [ApiConfig.defaultTimeout] on every request.
/// - Parsing responses and surfacing [ApiException] on non-2xx status codes.
///
/// You do **not** use this class directly — use [SchoolSystemService] or
/// [AiService] instead.
class ApiClient {
  final String baseUrl;
  final String apiKey;
  final http.Client _httpClient;

  ApiClient({
    required this.baseUrl,
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  // ─── Public helpers ───────────────────────────────────────────────────────

  /// Sends a GET request to [path] and returns the decoded JSON body.
  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = _buildUri(path, queryParams);
    final response = await _httpClient
        .get(uri, headers: _buildHeaders(extraHeaders))
        .timeout(ApiConfig.defaultTimeout);
    return _handleResponse(response);
  }

  /// Sends a POST request to [path] with a JSON [body].
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = _buildUri(path, null);
    final response = await _httpClient
        .post(
          uri,
          headers: _buildHeaders(extraHeaders),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.defaultTimeout);
    return _handleResponse(response);
  }

  /// Sends a PUT request to [path] with a JSON [body].
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = _buildUri(path, null);
    final response = await _httpClient
        .put(
          uri,
          headers: _buildHeaders(extraHeaders),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.defaultTimeout);
    return _handleResponse(response);
  }

  /// Sends a DELETE request to [path].
  Future<dynamic> delete(
    String path, {
    Map<String, String>? extraHeaders,
  }) async {
    final uri = _buildUri(path, null);
    final response = await _httpClient
        .delete(uri, headers: _buildHeaders(extraHeaders))
        .timeout(ApiConfig.defaultTimeout);
    return _handleResponse(response);
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  Uri _buildUri(String path, Map<String, String>? queryParams) {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse('$cleanBase$cleanPath');
    return queryParams != null
        ? uri.replace(queryParameters: queryParams)
        : uri;
  }

  Map<String, String> _buildHeaders([Map<String, String>? extra]) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      ...?extra,
    };
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    String message;
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      message = (json['message'] ?? json['error'] ?? response.reasonPhrase)
          .toString();
    } catch (_) {
      message = response.reasonPhrase ?? 'Unknown error';
    }

    throw ApiException(statusCode: response.statusCode, message: message);
  }

  void dispose() => _httpClient.close();
}
