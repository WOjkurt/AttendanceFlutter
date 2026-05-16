import 'dart:convert';

/// Data model for AI-computed merit score.
///
/// The AI service computes deduction points from a student's starting
/// merit (100) based on absences, lates, and improper uniform violations.
/// The result is a single integer score.
class AnalyticsResult {
  /// Computed merit score (starts at 100, deductions applied).
  final int meritScore;

  /// Timestamp when this result was produced.
  final DateTime generatedAt;

  /// AI-generated insights about the student's attendance patterns.
  final List<String> insights;

  const AnalyticsResult({
    required this.meritScore,
    required this.generatedAt,
    this.insights = const [],
  });

  // ─── JSON Serialisation (for shared_preferences cache) ──────────────────

  factory AnalyticsResult.fromJson(Map<String, dynamic> json) {
    return AnalyticsResult(
      meritScore: (json['meritScore'] as num?)?.toInt() ?? 100,
      generatedAt: DateTime.tryParse(json['generatedAt']?.toString() ?? '') ??
          DateTime.now(),
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'meritScore': meritScore,
        'generatedAt': generatedAt.toIso8601String(),
        'insights': insights,
      };

  /// Convenience: encode directly to a JSON string for cache storage.
  String toJsonString() => jsonEncode(toJson());

  /// Convenience: decode directly from a JSON string read from cache.
  static AnalyticsResult fromJsonString(String source) =>
      AnalyticsResult.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'AnalyticsResult(meritScore: $meritScore, insights: $insights)';
}
