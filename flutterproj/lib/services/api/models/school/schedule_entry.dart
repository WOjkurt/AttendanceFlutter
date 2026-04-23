/// Data Transfer Object for a class schedule entry from the school system.
///
/// Add, remove, or rename fields here once the real API contract is known.
class ScheduleEntry {
  final String classId;
  final String subjectName;
  final String room;

  /// 24-hour time string (e.g. '08:00').
  final String startTime;

  /// 24-hour time string (e.g. '09:30').
  final String endTime;

  /// Day of week as a string (e.g. 'Monday').
  final String day;

  /// TODO: Add more fields as the school system API contract is finalised.

  const ScheduleEntry({
    required this.classId,
    required this.subjectName,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.day,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      classId: json['classId']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'classId': classId,
    'subjectName': subjectName,
    'room': room,
    'startTime': startTime,
    'endTime': endTime,
    'day': day,
  };

  @override
  String toString() => 'ScheduleEntry($subjectName, $day $startTime-$endTime)';
}
