class Course {
  final int courseId;
  final String title;
  final String code;
  final String? description;
  final String teacherDocumentSeries;

  Course({
    required this.courseId,
    required this.title,
    required this.code,
    this.description,
    required this.teacherDocumentSeries,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['Course_ID'] ?? 0,
      title: json['Title'] ?? '',
      code: json['Code'] ?? '',
      description: json['Description'],
      teacherDocumentSeries: json['TeacherDocumentSeries'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Course_ID': courseId,
      'Title': title,
      'Code': code,
      'Description': description,
      'TeacherDocumentSeries': teacherDocumentSeries,
    };
  }

  Course copyWith({
    int? courseId,
    String? title,
    String? code,
    String? description,
    String? teacherDocumentSeries,
  }) {
    return Course(
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      code: code ?? this.code,
      description: description ?? this.description,
      teacherDocumentSeries: teacherDocumentSeries ?? this.teacherDocumentSeries,
    );
  }
}
