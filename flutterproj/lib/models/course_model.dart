class Course {
  final int courseId;
  final String title;
  final String code;
  final String teacherFullName;

  Course({
    required this.courseId,
    required this.title,
    required this.code,
    required this.teacherFullName,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['course_ID'] ?? json['Course_ID'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
      code: json['code'] ?? json['Code'] ?? '',
      teacherFullName: json['full_Name'] ?? json['Full_Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_ID': courseId,
      'Title': title,
      'Code': code,
      'full_Name': teacherFullName,
    };
  }

  Course copyWith({
    int? courseId,
    String? title,
    String? code,
    String? teacherFullName,
  }) {
    return Course(
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      code: code ?? this.code,
      teacherFullName: teacherFullName ?? this.teacherFullName,
    );
  }
}
