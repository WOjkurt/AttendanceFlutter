/// Data Transfer Object for an AI-generated attendance analysis result.
///
/// Add, remove, or rename fields here once the AI service API contract is known.
class AnalysisResult {
  /// Short summary produced by the AI model.
  final String summary;

  /// List of flagged anomalies (e.g. unusual absence patterns).
  final List<String> anomalies;

  /// Overall risk level: 'low' | 'medium' | 'high'
  final String riskLevel;

  /// TODO: Add more fields as the AI service API contract is finalised.

  const AnalysisResult({
    required this.summary,
    required this.anomalies,
    required this.riskLevel,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      summary: json['summary']?.toString() ?? '',
      anomalies: List<String>.from(
        (json['anomalies'] as List? ?? []).map((e) => e.toString()),
      ),
      riskLevel: json['riskLevel']?.toString() ?? 'low',
    );
  }

  Map<String, dynamic> toJson() => {
    'summary': summary,
    'anomalies': anomalies,
    'riskLevel': riskLevel,
  };

  @override
  String toString() => 'AnalysisResult(risk: $riskLevel)';
}
