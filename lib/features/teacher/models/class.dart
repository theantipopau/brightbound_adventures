/// Represents a class managed by a teacher
class StudentClass {
  final String id;
  final String teacherId;
  final String name; // e.g., "Grade 4A - 2024"
  final List<String> studentIds;
  final int gradeLevel; // 0=K, 1-6 for grades 1-6
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final bool isArchived;

  StudentClass({
    required this.id,
    required this.teacherId,
    required this.name,
    this.studentIds = const [],
    required this.gradeLevel,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.isArchived = false,
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

  /// Check if class has room for more students
  bool hasCapacity(int maxStudents) {
    return studentIds.length < maxStudents;
  }

  /// Check if student is in this class
  bool hasStudent(String studentId) {
    return studentIds.contains(studentId);
  }

  /// Get remaining capacity
  int getRemainingCapacity(int maxStudents) {
    return maxStudents - studentIds.length;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'name': name,
      'studentIds': studentIds,
      'gradeLevel': gradeLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'description': description,
      'isArchived': isArchived,
    };
  }

  /// Create from JSON
  factory StudentClass.fromJson(Map<String, dynamic> json) {
    return StudentClass(
      id: json['id'] ?? '',
      teacherId: json['teacherId'] ?? '',
      name: json['name'] ?? '',
      studentIds: List<String>.from(json['studentIds'] ?? []),
      gradeLevel: json['gradeLevel'] ?? 0,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : json['createdAt'] as DateTime,
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updatedAt'] as DateTime,
      description: json['description'],
      isArchived: json['isArchived'] ?? false,
    );
  }

  /// Create a copy with updated fields
  StudentClass copyWith({
    String? name,
    List<String>? studentIds,
    int? gradeLevel,
    String? description,
    bool? isArchived,
  }) {
    return StudentClass(
      id: id,
      teacherId: teacherId,
      name: name ?? this.name,
      studentIds: studentIds ?? this.studentIds,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  /// Add student to class (returns new instance)
  StudentClass addStudent(String studentId) {
    if (studentIds.contains(studentId)) return this;
    final newIds = [...studentIds, studentId];
    return copyWith(studentIds: newIds);
  }

  /// Remove student from class (returns new instance)
  StudentClass removeStudent(String studentId) {
    final newIds = studentIds.where((id) => id != studentId).toList();
    return copyWith(studentIds: newIds);
  }

  @override
  String toString() => 'StudentClass(id: $id, name: $name, grade: $gradeLevel, students: ${studentIds.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentClass &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          teacherId == other.teacherId;

  @override
  int get hashCode => id.hashCode ^ teacherId.hashCode;
}
