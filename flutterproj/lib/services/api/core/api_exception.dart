/// Typed exception thrown by every API service in this layer.
class ApiException implements Exception {
  /// HTTP status code, or –1 if the request never reached the server.
  final int statusCode;

  /// Human-readable reason (parsed from the response body or a default).
  final String message;

  const ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}
