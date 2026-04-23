/// Data Transfer Object for a student's profile received from the school system.
///
/// Add, remove, or rename fields here once the real API contract is known.
class StudentProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  /// TODO: Add more fields as the school system API contract is finalised.

  const StudentProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
  };

  @override
  String toString() => 'StudentProfile($id, $firstName $lastName)';
}
