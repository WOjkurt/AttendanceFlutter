import 'enums/att_status.dart';

class AttendanceStudent {
  final int attendanceId;
  final String studentDocumentSeries;
  final AttStatus studentAttendanceStatus;

  AttendanceStudent({
    required this.attendanceId,
    required this.studentDocumentSeries,
    required this.studentAttendanceStatus,
  });

  factory AttendanceStudent.fromJson(Map<String, dynamic> json) {
    return AttendanceStudent(
      attendanceId: json['Attendance_Id'] ?? 0,
      studentDocumentSeries: json['StudentDocumentSeries'] ?? '',
      studentAttendanceStatus: AttStatus.fromJson(json['StudentAttendanceStatus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Attendance_Id': attendanceId,
      'StudentDocumentSeries': studentDocumentSeries,
      'StudentAttendanceStatus': studentAttendanceStatus.toJson(),
    };
  }

  AttendanceStudent copyWith({
    int? attendanceId,
    String? studentDocumentSeries,
    AttStatus? studentAttendanceStatus,
  }) {
    return AttendanceStudent(
      attendanceId: attendanceId ?? this.attendanceId,
      studentDocumentSeries: studentDocumentSeries ?? this.studentDocumentSeries,
      studentAttendanceStatus: studentAttendanceStatus ?? this.studentAttendanceStatus,
    );
  }
}
