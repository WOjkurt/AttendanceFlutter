/// Central place to configure all external API base URLs and shared headers.
///
/// Replace the placeholder strings with the real endpoints when they are ready.
/// The app reads these values at runtime, so you only need to change them here.
class ApiConfig {
  ApiConfig._(); // prevent instantiation

  // ─── School System ────────────────────────────────────────────────────────
  /// Base URL of the main school management system.
  /// Example: 'https://school.dbtc-cebu.edu.ph/api'
  static const String schoolSystemBaseUrl = 'YOUR_SCHOOL_SYSTEM_BASE_URL';

  /// Shared secret / API key expected by the school system.
  /// Leave empty if the school system uses a different auth scheme.
  static const String schoolSystemApiKey = 'YOUR_SCHOOL_SYSTEM_API_KEY';

  // ─── AI Service ───────────────────────────────────────────────────────────
  /// Base URL of the AI integration service.
  /// Example: 'https://ai.dbtc-cebu.edu.ph/api'
  static const String aiServiceBaseUrl = 'YOUR_AI_SERVICE_BASE_URL';

  /// API key / bearer token for the AI service.
  static const String aiServiceApiKey = 'YOUR_AI_SERVICE_API_KEY';

  // ─── Shared ───────────────────────────────────────────────────────────────
  /// Default request timeout applied to every call.
  static const Duration defaultTimeout = Duration(seconds: 30);
}
