class Section {
  final int sectionId;
  final String? sectionCode;

  Section({
    required this.sectionId,
    this.sectionCode,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionId: json['Section_Id'] ?? 0,
      sectionCode: json['Section_Code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Section_Id': sectionId,
      'Section_Code': sectionCode,
    };
  }

  Section copyWith({
    int? sectionId,
    String? sectionCode,
  }) {
    return Section(
      sectionId: sectionId ?? this.sectionId,
      sectionCode: sectionCode ?? this.sectionCode,
    );
  }
}
