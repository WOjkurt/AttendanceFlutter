/// Data Transfer Object for an AI-generated attendance risk prediction.
///
/// Add, remove, or rename fields here once the AI service API contract is known.
class RiskPrediction {
  final String studentId;

  /// Risk score in the range 0.0 (no risk) to 1.0 (certain risk).
  final double score;

  /// Human-readable reasoning from the model explaining the score.
  final String reasoning;

  /// Categorical label derived from [score]: 'low' | 'medium' | 'high'
  String get label {
    if (score < 0.33) return 'low';
    if (score < 0.66) return 'medium';
    return 'high';
  }

  /// TODO: Add more fields as the AI service API contract is finalised.

  const RiskPrediction({
    required this.studentId,
    required this.score,
    required this.reasoning,
  });

  factory RiskPrediction.fromJson(Map<String, dynamic> json) {
    return RiskPrediction(
      studentId: json['studentId']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      reasoning: json['reasoning']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'score': score,
    'reasoning': reasoning,
  };

  @override
  String toString() =>
      'RiskPrediction($studentId, score: ${score.toStringAsFixed(2)}, $label)';
}
