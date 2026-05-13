import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analytics_result.dart';

/// Repository that orchestrates AI analytics data flow.
///
/// Responsibilities:
/// - Hashing attendance data to detect changes.
/// - Reading / writing cached results via [SharedPreferences].
/// - Deciding whether to use the cache or call the AI service.
/// - Calling the (currently stubbed) AI service.
///
/// ─── Integration guide ─────────────────────────────────────────────────────
/// When the real AI service is ready:
/// 1. Import your [AiController] from `services/api/controllers/ai_controller.dart`.
/// 2. Accept it as a constructor parameter (like [AuthBloc] accepts [AuthService]).
/// 3. Replace the body of [_callAiService] with the real API call.
/// ────────────────────────────────────────────────────────────────────────────
class AnalyticsRepository {
  // ─── Cache keys ──────────────────────────────────────────────────────────
  static const _cacheResultKey = 'analytics_cache_result';
  static const _cacheHashKey = 'analytics_cache_hash';
  static const _cacheTimestampKey = 'analytics_cache_timestamp';

  /// Maximum age of a valid cache entry.
  static const _cacheDuration = Duration(days: 30);

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Returns an [AnalyticsResult] for the given attendance [data].
  ///
  /// By default, a cached result is returned when:
  /// 1. The SHA-256 hash of [data] matches the cached hash, AND
  /// 2. The cache is less than 30 days old.
  ///
  /// Set [forceRefresh] to `true` to bypass the cache entirely
  /// (e.g. when the user taps the refresh button).
  ///
  /// Returns a record `(AnalyticsResult result, bool fromCache)`.
  Future<({AnalyticsResult result, bool fromCache})> getAnalytics(
    Map<String, dynamic> data, {
    bool forceRefresh = false,
  }) async {
    final currentHash = _computeDataHash(data);

    if (!forceRefresh) {
      final cached = await _readCache();
      if (cached != null && await _isCacheValid(currentHash)) {
        return (result: cached, fromCache: true);
      }
    }

    // Cache miss or force refresh — call the AI service.
    final result = await _callAiService(data);

    // Persist the fresh result.
    await _writeCache(result, currentHash);

    return (result: result, fromCache: false);
  }

  // ─── Hashing ─────────────────────────────────────────────────────────────

  /// Computes a SHA-256 digest of the attendance data map.
  ///
  /// The map is JSON-encoded with sorted keys so that key order doesn't
  /// affect the hash.
  String _computeDataHash(Map<String, dynamic> data) {
    final jsonString = jsonEncode(_sortedMap(data));
    final bytes = utf8.encode(jsonString);
    return sha256.convert(bytes).toString();
  }

  /// Recursively sorts map keys for deterministic hashing.
  Map<String, dynamic> _sortedMap(Map<String, dynamic> map) {
    final sorted = <String, dynamic>{};
    for (final key in map.keys.toList()..sort()) {
      final value = map[key];
      if (value is Map<String, dynamic>) {
        sorted[key] = _sortedMap(value);
      } else {
        sorted[key] = value;
      }
    }
    return sorted;
  }

  // ─── Cache ───────────────────────────────────────────────────────────────

  Future<AnalyticsResult?> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheResultKey);
    if (jsonString == null) return null;

    try {
      return AnalyticsResult.fromJsonString(jsonString);
    } catch (_) {
      // Corrupted cache — treat as cache miss.
      return null;
    }
  }

  Future<void> _writeCache(AnalyticsResult result, String hash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheResultKey, result.toJsonString());
    await prefs.setString(_cacheHashKey, hash);
    await prefs.setString(
      _cacheTimestampKey,
      DateTime.now().toIso8601String(),
    );
  }

  Future<bool> _isCacheValid(String currentHash) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedHash = prefs.getString(_cacheHashKey);
    final cachedTimestamp = prefs.getString(_cacheTimestampKey);

    if (cachedHash == null || cachedTimestamp == null) return false;

    // Condition 1: data hash must match.
    if (cachedHash != currentHash) return false;

    // Condition 2: cache must be less than 30 days old.
    final timestamp = DateTime.tryParse(cachedTimestamp);
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  // ─── AI Service Call (Stubbed) ───────────────────────────────────────────

  /// Calls the AI service with the given attendance [data] and returns
  /// an [AnalyticsResult].
  ///
  /// TODO: ──────────────────────────────────────────────────────────────────
  /// REPLACE THIS STUB with a real AI service call when the service is ready.
  ///
  /// Integration steps:
  /// 1. Add an [AiController] field to this repository.
  /// 2. Call `_aiController.analyzeAttendance(data)` here.
  /// 3. Map the response to an [AnalyticsResult].
  ///
  /// Example:
  /// ```dart
  /// Future<AnalyticsResult> _callAiService(Map<String, dynamic> data) async {
  ///   final analysis = await _aiController.analyzeAttendance(data);
  ///   return AnalyticsResult(
  ///     meritScore: analysis.computedMeritScore,
  ///     generatedAt: DateTime.now(),
  ///   );
  /// }
  /// ```
  /// ────────────────────────────────────────────────────────────────────────
  Future<AnalyticsResult> _callAiService(Map<String, dynamic> data) async {
    // Simulate network latency for realistic UX during development.
    await Future.delayed(const Duration(milliseconds: 800));

    // ── Stub: compute merit deductions locally ──────────────────────────
    // Starting merit = 100.
    // Deductions:  absent = -5,  late = -3
    // TODO: Replace this local computation with the real AI service call
    //       once the AI endpoint is available. The AI may also factor in
    //       improper uniform and other violations.
    const startingMerit = 100;
    final absences = (data['totalAbsences'] as int?) ?? 0;
    final lates = (data['totalLates'] as int?) ?? 0;

    final score = (startingMerit - (absences * 5) - (lates * 3)).clamp(0, 100);

    return AnalyticsResult(
      meritScore: score,
      generatedAt: DateTime.now(),
    );
  }
}
