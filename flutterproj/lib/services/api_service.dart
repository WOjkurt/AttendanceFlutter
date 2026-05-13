import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
    debugPrint('=== API RESPONSE ===');
    debugPrint('URL: ${response.request?.url}');
    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('BODY: ${response.body}');
    debugPrint('====================');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        final body = jsonDecode(response.body);
        switch (response.statusCode) {
          case 200:
          case 201:
            if (body is Map<String, dynamic> && body.containsKey('data')) {
              return {'data': body['data']};
            }
            return body is Map<String, dynamic> ? body : {'data': body};
          default:
            return body;
        }
      } catch (e) {
        return response.body;
      }
    } else {
      String message = response.reasonPhrase ?? 'Unknown error';
      try {
        final body = jsonDecode(response.body);
        message = body['detail'] ?? body['message'] ?? message;
      } catch (_) {}

      throw ApiException(statusCode: response.statusCode, message: message);
    }
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      debugPrint('=== API REQUEST ===');
      debugPrint('METHOD: GET');
      debugPrint('URL: $baseUrl$endpoint');
      debugPrint('HAS TOKEN: ${await _tokenController.getToken() != null}');
      debugPrint('===================');
      final headers = await _getHeaders(requiresAuth);
      final response = await _client
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 60)); // 60s for Render cold start
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(statusCode: 408, message: 'Server is waking up, please try again in a moment.');
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body, bool requiresAuth = true}) async {
    try {
      debugPrint('=== API REQUEST ===');
      debugPrint('METHOD: POST');
      debugPrint('URL: $baseUrl$endpoint');
      debugPrint('HAS TOKEN: ${await _tokenController.getToken() != null}');
      debugPrint('===================');
      final headers = await _getHeaders(requiresAuth);
      final response = await _client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 60));
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(statusCode: 408, message: 'Server is waking up, please try again in a moment.');
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body, bool requiresAuth = true}) async {
    try {
      debugPrint('=== API REQUEST ===');
      debugPrint('METHOD: PUT');
      debugPrint('URL: $baseUrl$endpoint');
      debugPrint('HAS TOKEN: ${await _tokenController.getToken() != null}');
      debugPrint('===================');
      final headers = await _getHeaders(requiresAuth);
      final response = await _client
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 60));
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(statusCode: 408, message: 'Server is waking up, please try again in a moment.');
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      debugPrint('=== API REQUEST ===');
      debugPrint('METHOD: DELETE');
      debugPrint('URL: $baseUrl$endpoint');
      debugPrint('HAS TOKEN: ${await _tokenController.getToken() != null}');
      debugPrint('===================');
      final headers = await _getHeaders(requiresAuth);
      final response = await _client
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 60));
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(statusCode: 408, message: 'Server is waking up, please try again in a moment.');
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection.');
    }
  }
}
