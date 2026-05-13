enum AttStatus {
  present,
  absent,
  late,
  excused,
  unknown;

  static AttStatus fromJson(dynamic value) {
    if (value == null) return AttStatus.unknown;
    final strValue = value.toString().toLowerCase();
    switch (strValue) {
      case 'present':
        return AttStatus.present;
      case 'absent':
        return AttStatus.absent;
      case 'late':
        return AttStatus.late;
      case 'excused':
        return AttStatus.excused;
      default:
        return AttStatus.unknown;
    }
  }

  String toJson() {
    return name;
  }
}
