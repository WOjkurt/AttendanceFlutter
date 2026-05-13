class UserModel {
  final String id;
  final String email;
  final String userName;
  final String documentSeries;
  final String fullName;
  final String? phoneNumber;
  final String? sex;
  final DateTime? birthDate;
  final String? address;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final String? createdBy;
  final String? lastUpdatedBy;

  UserModel({
    required this.id,
    required this.email,
    required this.userName,
    required this.documentSeries,
    required this.fullName,
    this.phoneNumber,
    this.sex,
    this.birthDate,
    this.address,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.createdBy,
    this.lastUpdatedBy,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['Id'] ?? '',
      email: json['Email'] ?? '',
      userName: json['UserName'] ?? '',
      documentSeries: json['DocumentSeries'] ?? '',
      fullName: json['Full_Name'] ?? '',
      phoneNumber: json['Phone_Number'],
      sex: json['Sex'],
      birthDate: json['Birth_Date'] != null 
          ? DateTime.tryParse(json['Birth_Date']) 
          : null,
      address: json['Address'],
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
      'Id': id,
      'Email': email,
      'UserName': userName,
      'DocumentSeries': documentSeries,
      'Full_Name': fullName,
      'Phone_Number': phoneNumber,
      'Sex': sex,
      'Birth_Date': birthDate?.toIso8601String(),
      'Address': address,
      'CreatedAt': createdAt.toIso8601String(),
      'LastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'CreatedBy': createdBy,
      'LastUpdatedBy': lastUpdatedBy,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? userName,
    String? documentSeries,
    String? fullName,
    String? phoneNumber,
    String? sex,
    DateTime? birthDate,
    String? address,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    String? createdBy,
    String? lastUpdatedBy,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      documentSeries: documentSeries ?? this.documentSeries,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      createdBy: createdBy ?? this.createdBy,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }
}
