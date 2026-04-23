/// Data Transfer Object for a single attendance record from the school system.
///
/// Add, remove, or rename fields here once the real API contract is known.
class AttendanceRecord {
  final String studentId;
  final String classId;

  /// ISO-8601 date string (e.g. '2026-04-19').
  final String date;

  /// e.g. 'present', 'absent', 'late', 'excused'
  final String status;

  /// TODO: Add more fields as the school system API contract is finalised.

  const AttendanceRecord({
    required this.studentId,
    required this.classId,
    required this.date,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      studentId: json['studentId']?.toString() ?? '',
      classId: json['classId']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'classId': classId,
    'date': date,
    'status': status,
  };

  @override
  String toString() => 'AttendanceRecord($studentId, $date, $status)';
}
