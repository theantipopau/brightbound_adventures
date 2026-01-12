/// Represents a student user in the app
class StudentUser {
  final String id;
  final String name;
  final int gradeLevel; // 0=K, 1-6 for grades 1-6
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatarUrl;
  final bool isActive;
  
  // NEW: Teacher linking fields
  final String? teacherId; // Which teacher manages this student
  final String? classId; // Which class this student belongs to
  
  // Progress tracking
  final int totalQuestionsAnswered;
  final int currentStreak; // days
  final DateTime? lastActiveDate;

  StudentUser({
    required this.id,
    required this.name,
    required this.gradeLevel,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
    this.isActive = true,
    this.teacherId,
    this.classId,
    this.totalQuestionsAnswered = 0,
    this.currentStreak = 0,
    this.lastActiveDate,
  });

  /// Get human-readable grade level
  String get gradeLevelLabel {
    switch (gradeLevel) {
      case 0:
        return 'Kindergarten';
      case 1:
        return 'Grade 1';
      case 2:
        return 'Grade 2';
      case 3:
        return 'Grade 3';
      case 4:
        return 'Grade 4';
      case 5:
        return 'Grade 5';
      case 6:
        return 'Grade 6';
      default:
        return 'Unknown';
    }
  }

  /// Check if student is linked to a teacher/class
  bool get isLinkedToClass {
    return teacherId != null && classId != null;
  }

  /// Check if student is currently active (last active within 7 days)
  bool get isCurrentlyActive {
    if (lastActiveDate == null) return false;
    final daysAgo = DateTime.now().difference(lastActiveDate!).inDays;
    return daysAgo <= 7;
  }

  /// Get days since last active
  int? get daysSinceLastActive {
    if (lastActiveDate == null) return null;
    return DateTime.now().difference(lastActiveDate!).inDays;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gradeLevel': gradeLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'teacherId': teacherId,
      'classId': classId,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'currentStreak': currentStreak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory StudentUser.fromJson(Map<String, dynamic> json) {
    return StudentUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      gradeLevel: json['gradeLevel'] ?? 0,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : json['createdAt'] as DateTime,
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updatedAt'] as DateTime,
      avatarUrl: json['avatarUrl'],
      isActive: json['isActive'] ?? true,
      teacherId: json['teacherId'],
      classId: json['classId'],
      totalQuestionsAnswered: json['totalQuestionsAnswered'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  StudentUser copyWith({
    String? name,
    int? gradeLevel,
    String? avatarUrl,
    bool? isActive,
    String? teacherId,
    String? classId,
    int? totalQuestionsAnswered,
    int? currentStreak,
    DateTime? lastActiveDate,
  }) {
    return StudentUser(
      id: id,
      name: name ?? this.name,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      teacherId: teacherId ?? this.teacherId,
      classId: classId ?? this.classId,
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  /// Link student to teacher and class
  StudentUser linkToClass(String newTeacherId, String newClassId) {
    return copyWith(
      teacherId: newTeacherId,
      classId: newClassId,
    );
  }

  /// Unlink student from teacher and class
  StudentUser unlinkFromClass() {
    return copyWith(
      teacherId: null,
      classId: null,
    );
  }

  /// Update last active timestamp
  StudentUser updateLastActive() {
    return copyWith(lastActiveDate: DateTime.now());
  }

  /// Increment streak
  StudentUser incrementStreak() {
    return copyWith(currentStreak: currentStreak + 1);
  }

  /// Reset streak
  StudentUser resetStreak() {
    return copyWith(currentStreak: 0);
  }

  /// Add question answered
  StudentUser addQuestionAnswered() {
    return copyWith(totalQuestionsAnswered: totalQuestionsAnswered + 1);
  }

  @override
  String toString() => 'StudentUser(id: $id, name: $name, grade: $gradeLevel, teacher: $teacherId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentUser &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
