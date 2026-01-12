/// Represents a teacher account with license and class management capabilities
class TeacherAccount {
  final String id;
  final String email;
  final String fullName;
  final String schoolName;
  final String licenseType; // 'free' | 'starter' | 'professional' | 'enterprise'
  final DateTime createdAt;
  final DateTime licenseExpiresAt;
  final List<String> classIds;
  final int maxStudents;
  final bool isActive;
  final String? phoneNumber;
  final String? schoolDistrict;
  final String? gradeSpecialty; // e.g., "K", "1-2", "3-5", "6+"

  TeacherAccount({
    required this.id,
    required this.email,
    required this.fullName,
    required this.schoolName,
    this.licenseType = 'free',
    required this.createdAt,
    required this.licenseExpiresAt,
    this.classIds = const [],
    this.maxStudents = 5, // Default 5 for free tier
    this.isActive = true,
    this.phoneNumber,
    this.schoolDistrict,
    this.gradeSpecialty,
  });

  /// Get remaining license duration in days
  int get daysUntilExpiry {
    return licenseExpiresAt.difference(DateTime.now()).inDays;
  }

  /// Check if license is expired
  bool get isExpired {
    return DateTime.now().isAfter(licenseExpiresAt);
  }

  /// Get max students based on license tier
  static int getMaxStudentsForTier(String licenseType) {
    switch (licenseType) {
      case 'free':
        return 5;
      case 'starter':
        return 15;
      case 'professional':
        return 30;
      case 'enterprise':
        return 999; // Unlimited effectively
      default:
        return 5;
    }
  }

  /// Get license tier price in cents (for display)
  static int getPriceForTier(String licenseType) {
    switch (licenseType) {
      case 'free':
        return 0;
      case 'starter':
        return 29900; // $299
      case 'professional':
        return 59900; // $599
      case 'enterprise':
        return 0; // Custom
      default:
        return 0;
    }
  }

  /// Get human-readable license price
  static String getPriceLabelForTier(String licenseType) {
    switch (licenseType) {
      case 'free':
        return 'Free';
      case 'starter':
        return '\$299/year';
      case 'professional':
        return '\$599/year';
      case 'enterprise':
        return 'Custom pricing';
      default:
        return 'Unknown';
    }
  }

  /// Convert to JSON for API/storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'schoolName': schoolName,
      'licenseType': licenseType,
      'createdAt': createdAt.toIso8601String(),
      'licenseExpiresAt': licenseExpiresAt.toIso8601String(),
      'classIds': classIds,
      'maxStudents': maxStudents,
      'isActive': isActive,
      'phoneNumber': phoneNumber,
      'schoolDistrict': schoolDistrict,
      'gradeSpecialty': gradeSpecialty,
    };
  }

  /// Create from JSON
  factory TeacherAccount.fromJson(Map<String, dynamic> json) {
    return TeacherAccount(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      schoolName: json['schoolName'] ?? '',
      licenseType: json['licenseType'] ?? 'free',
      createdAt: json['createdAt'] is String 
          ? DateTime.parse(json['createdAt'] as String)
          : json['createdAt'] as DateTime,
      licenseExpiresAt: json['licenseExpiresAt'] is String
          ? DateTime.parse(json['licenseExpiresAt'] as String)
          : json['licenseExpiresAt'] as DateTime,
      classIds: List<String>.from(json['classIds'] ?? []),
      maxStudents: json['maxStudents'] ?? 5,
      isActive: json['isActive'] ?? true,
      phoneNumber: json['phoneNumber'],
      schoolDistrict: json['schoolDistrict'],
      gradeSpecialty: json['gradeSpecialty'],
    );
  }

  /// Create a copy with updated fields
  TeacherAccount copyWith({
    String? email,
    String? fullName,
    String? schoolName,
    String? licenseType,
    DateTime? licenseExpiresAt,
    List<String>? classIds,
    int? maxStudents,
    bool? isActive,
    String? phoneNumber,
    String? schoolDistrict,
    String? gradeSpecialty,
  }) {
    return TeacherAccount(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      schoolName: schoolName ?? this.schoolName,
      licenseType: licenseType ?? this.licenseType,
      createdAt: createdAt,
      licenseExpiresAt: licenseExpiresAt ?? this.licenseExpiresAt,
      classIds: classIds ?? this.classIds,
      maxStudents: maxStudents ?? this.maxStudents,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      schoolDistrict: schoolDistrict ?? this.schoolDistrict,
      gradeSpecialty: gradeSpecialty ?? this.gradeSpecialty,
    );
  }

  @override
  String toString() => 'TeacherAccount(id: $id, email: $email, name: $fullName, license: $licenseType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherAccount &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
