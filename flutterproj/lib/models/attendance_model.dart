import 'enums/att_status.dart';

class Attendance {
  final int attendanceId;
  final int scheduleId;
  final AttStatus teacherStatus;
  final DateTime date;
  final DateTime createdAt;
  final String? createdBy;

  Attendance({
    required this.attendanceId,
    required this.scheduleId,
    required this.teacherStatus,
    required this.date,
    required this.createdAt,
    this.createdBy,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceId: json['Attendance_ID'] ?? 0,
      scheduleId: json['Schedule_ID'] ?? 0,
      teacherStatus: AttStatus.fromJson(json['TeacherStatus']),
      date: json['Date'] != null ? DateTime.parse(json['Date']) : DateTime.now(),
      createdAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : DateTime.now(),
      createdBy: json['CreatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Attendance_ID': attendanceId,
      'Schedule_ID': scheduleId,
      'TeacherStatus': teacherStatus.toJson(),
      'Date': date.toIso8601String().split('T')[0],
      'CreatedAt': createdAt.toIso8601String(),
      'CreatedBy': createdBy,
    };
  }

  Attendance copyWith({
    int? attendanceId,
    int? scheduleId,
    AttStatus? teacherStatus,
    DateTime? date,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Attendance(
      attendanceId: attendanceId ?? this.attendanceId,
      scheduleId: scheduleId ?? this.scheduleId,
      teacherStatus: teacherStatus ?? this.teacherStatus,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
