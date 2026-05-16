class Schedule {
  final int scheduleId;
  final int courseId;
  final int sectionId;
  final int dayOfWeek;
  final int semester;
  final String academicYear;
  final String startTime;
  final String endTime;

  Schedule({
    required this.scheduleId,
    required this.courseId,
    required this.sectionId,
    required this.dayOfWeek,
    required this.semester,
    required this.academicYear,
    required this.startTime,
    required this.endTime,
  });

  String get dayName {
    switch (dayOfWeek) {
      case 0: return 'Sunday';
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      default: return 'Unknown';
    }
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['Schedule_Id'] ?? 0,
      courseId: json['Course_ID'] ?? 0,
      sectionId: json['Section_ID'] ?? 0,
      dayOfWeek: json['DayOfWeek'] ?? 0,
      semester: json['Semester'] ?? 0,
      academicYear: json['AcademicYear'] ?? '',
      startTime: json['StartTime'] ?? '',
      endTime: json['EndTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Schedule_Id': scheduleId,
      'Course_ID': courseId,
      'Section_ID': sectionId,
      'DayOfWeek': dayOfWeek,
      'Semester': semester,
      'AcademicYear': academicYear,
      'StartTime': startTime,
      'EndTime': endTime,
    };
  }

  Schedule copyWith({
    int? scheduleId,
    int? courseId,
    int? sectionId,
    int? dayOfWeek,
    int? semester,
    String? academicYear,
    String? startTime,
    String? endTime,
  }) {
    return Schedule(
      scheduleId: scheduleId ?? this.scheduleId,
      courseId: courseId ?? this.courseId,
      sectionId: sectionId ?? this.sectionId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class DaySchedule {
  final String title;
  final String startTime;
  final String endTime;

  DaySchedule({
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      title: json['title'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }
}
