/// Data Transfer Object for an AI-generated class summary report.
///
/// Add, remove, or rename fields here once the AI service API contract is known.
class SummaryReport {
  final String classId;
  final String startDate;
  final String endDate;

  /// Overall attendance rate as a percentage (0.0 – 100.0).
  final double attendanceRate;

  /// Narrative summary produced by the AI model.
  final String narrative;

  /// TODO: Add more fields as the AI service API contract is finalised.

  const SummaryReport({
    required this.classId,
    required this.startDate,
    required this.endDate,
    required this.attendanceRate,
    required this.narrative,
  });

  factory SummaryReport.fromJson(Map<String, dynamic> json) {
    return SummaryReport(
      classId: json['classId']?.toString() ?? '',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      attendanceRate:
          (json['attendanceRate'] as num?)?.toDouble() ?? 0.0,
      narrative: json['narrative']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'classId': classId,
    'startDate': startDate,
    'endDate': endDate,
    'attendanceRate': attendanceRate,
    'narrative': narrative,
  };

  @override
  String toString() =>
      'SummaryReport($classId, ${attendanceRate.toStringAsFixed(1)}%)';
}
