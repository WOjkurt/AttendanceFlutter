class Student {
  final String userDocumentSeries;
  final String documentSeries;
  final int programId;
  final int departmentId;
  final int sectionId;
  final int yearLevel;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final String? createdBy;
  final String? lastUpdatedBy;

  Student({
    required this.userDocumentSeries,
    required this.documentSeries,
    required this.programId,
    required this.departmentId,
    required this.sectionId,
    required this.yearLevel,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.createdBy,
    this.lastUpdatedBy,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      userDocumentSeries: json['UserDocumentSeries'] ?? '',
      documentSeries: json['DocumentSeries'] ?? '',
      programId: json['Program_ID'] ?? 0,
      departmentId: json['Department_ID'] ?? 0,
      sectionId: json['SectionID'] ?? 0,
      yearLevel: json['Year_Level'] ?? 0,
      createdAt: json['CreatedAt'] != null 
          ? DateTime.parse(json['CreatedAt']) 
          : DateTime.now(),
      lastUpdatedAt: json['LastUpdatedAt'] != null 
          ? DateTime.parse(json['LastUpdatedAt']) 
          : DateTime.now(),
      createdBy: json['CreatedBy'],
      lastUpdatedBy: json['LastUpdatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserDocumentSeries': userDocumentSeries,
      'DocumentSeries': documentSeries,
      'Program_ID': programId,
      'Department_ID': departmentId,
      'SectionID': sectionId,
      'Year_Level': yearLevel,
      'CreatedAt': createdAt.toIso8601String(),
      'LastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'CreatedBy': createdBy,
      'LastUpdatedBy': lastUpdatedBy,
    };
  }

  Student copyWith({
    String? userDocumentSeries,
    String? documentSeries,
    int? programId,
    int? departmentId,
    int? sectionId,
    int? yearLevel,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    String? createdBy,
    String? lastUpdatedBy,
  }) {
    return Student(
      userDocumentSeries: userDocumentSeries ?? this.userDocumentSeries,
      documentSeries: documentSeries ?? this.documentSeries,
      programId: programId ?? this.programId,
      departmentId: departmentId ?? this.departmentId,
      sectionId: sectionId ?? this.sectionId,
      yearLevel: yearLevel ?? this.yearLevel,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      createdBy: createdBy ?? this.createdBy,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }
}

class AddStudentRequest {
  final int userId;
  final int programId;
  final int sectionId;
  final int departmentId;
  final int yearLevel;

  AddStudentRequest({
    required this.userId,
    required this.programId,
    required this.sectionId,
    required this.departmentId,
    required this.yearLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'User_ID': userId,
      'Program_ID': programId,
      'SectionID': sectionId,
      'Department_ID': departmentId,
      'Year_Level': yearLevel,
    };
  }
}
