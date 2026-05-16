import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../controllers/token_controller.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $statusCode - $message';
}

class ApiService {
  final TokenController _tokenController = TokenController();
  final String baseUrl = 'https://k-group-ams-dbtc-11f4.onrender.com';
  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      final token = await _tokenController.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (kDebugMode) {
      debugPrint(
        'STATUS: ${response.statusCode} URL: ${response.request?.url}',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'data': []};

      dynamic body;
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        return {'data': response.body};
      }

      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return {'data': body['data']};
      }
      if (body is List) return {'data': body};
      if (body is Map<String, dynamic>) return body;
      return {'data': body};
    } else {
      String message;
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          message =
              body['detail'] ??
              body['message'] ??
              _statusMessage(response.statusCode);
        } else {
          message = _statusMessage(response.statusCode);
        }
      } catch (_) {
        message = _statusMessage(response.statusCode);
      }

      throw ApiException(statusCode: response.statusCode, message: message);
    }
  }

  String _statusMessage(int code) {
    switch (code) {
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to do this.';
      case 404:
        return 'Resource not found.';
      case 408:
        return 'Server is waking up, please try again in a moment.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong ($code).';
    }
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final response = await _client
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 120));
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message: 'Server is waking up, please try again in a moment.',
      );
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  /// Fetches a binary response (e.g. PNG image) and returns the raw bytes.
  ///
  /// Use this instead of [get] for endpoints that return non-JSON content.
  /// [requiresAuth] defaults to false since GET /api/Student/{id}/qr
  /// is publicly accessible per the backend config.
  Future<Uint8List> getBytes(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      // Remove JSON Accept header — we want the raw binary response.
      headers['Accept'] = '*/*';

      final response = await _client
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 120));

      if (kDebugMode) {
        debugPrint(
          'STATUS: ${response.statusCode} URL: ${response.request?.url}',
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: _statusMessage(response.statusCode),
      );
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message: 'Server is waking up, please try again in a moment.',
      );
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final response = await _client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 120));
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message: 'Server is waking up, please try again in a moment.',
      );
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final response = await _client
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 120));
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message: 'Server is waking up, please try again in a moment.',
      );
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final response = await _client
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 120));
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message: 'Server is waking up, please try again in a moment.',
      );
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  /// Close the HTTP client when no longer needed.
  void dispose() => _client.close();
}
