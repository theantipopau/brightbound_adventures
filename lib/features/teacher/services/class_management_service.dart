import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/class.dart';

/// Service for managing teacher classes via Cloudflare Workers API
class ClassManagementService {
  final String apiBase;
  final http.Client httpClient;
  final String authToken;

  ClassManagementService({
    String? apiBase,
    required this.authToken,
    http.Client? httpClient,
  })  : apiBase = apiBase ?? 'https://brightbound-api.matt-hurley91.workers.dev',
        httpClient = httpClient ?? http.Client();

  /// Create a new class for a teacher
  Future<StudentClass?> createClass({
    required String teacherId,
    required String name,
    required int gradeLevel,
    String? description,
  }) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$apiBase/api/classes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'teacherId': teacherId,
          'name': name,
          'gradeLevel': gradeLevel,
          'description': description,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return StudentClass.fromJson(data['class']);
      } else if (response.statusCode == 402) {
        throw Exception('Maximum classes reached for your license tier');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      return null;
    } catch (e) {
      debugPrint('Error creating class: $e');
      rethrow;
    }
  }

  /// Get all classes for a teacher
  Future<List<StudentClass>> getTeacherClasses(String teacherId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$apiBase/api/teachers/$teacherId/classes'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final classes = (data['classes'] as List)
            .map((c) => StudentClass.fromJson(c as Map<String, dynamic>))
            .toList();
        return classes;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      return [];
    } catch (e) {
      debugPrint('Error getting teacher classes: $e');
      return [];
    }
  }

  /// Get a single class by ID
  Future<StudentClass?> getClass(String classId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$apiBase/api/classes/$classId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return StudentClass.fromJson(data['class']);
      } else if (response.statusCode == 404) {
        return null;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting class: $e');
      return null;
    }
  }

  /// Update class details
  Future<StudentClass?> updateClass({
    required String classId,
    String? name,
    String? description,
    int? gradeLevel,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (gradeLevel != null) body['gradeLevel'] = gradeLevel;

      final response = await httpClient.patch(
        Uri.parse('$apiBase/api/classes/$classId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return StudentClass.fromJson(data['class']);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      return null;
    } catch (e) {
      debugPrint('Error updating class: $e');
      rethrow;
    }
  }

  /// Archive a class (soft delete)
  Future<void> archiveClass(String classId) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$apiBase/api/classes/$classId/archive'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to archive class');
      }
    } catch (e) {
      debugPrint('Error archiving class: $e');
      rethrow;
    }
  }

  /// Add student to class
  Future<StudentClass?> addStudentToClass({
    required String classId,
    required String studentId,
  }) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$apiBase/api/classes/$classId/students'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'studentId': studentId,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return StudentClass.fromJson(data['class']);
      } else if (response.statusCode == 409) {
        throw Exception('Student already in class');
      } else if (response.statusCode == 402) {
        throw Exception('Class at maximum capacity');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      return null;
    } catch (e) {
      debugPrint('Error adding student to class: $e');
      rethrow;
    }
  }

  /// Remove student from class
  Future<StudentClass?> removeStudentFromClass({
    required String classId,
    required String studentId,
  }) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$apiBase/api/classes/$classId/students/$studentId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return StudentClass.fromJson(data['class']);
      } else if (response.statusCode == 404) {
        return null;
      }
      return null;
    } catch (e) {
      debugPrint('Error removing student from class: $e');
      rethrow;
    }
  }

  /// Bulk add students to class
  Future<StudentClass?> bulkAddStudents({
    required String classId,
    required List<String> studentIds,
  }) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$apiBase/api/classes/$classId/students/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'studentIds': studentIds,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return StudentClass.fromJson(data['class']);
      } else if (response.statusCode == 402) {
        throw Exception('Cannot add all students - would exceed capacity');
      }
      return null;
    } catch (e) {
      debugPrint('Error bulk adding students: $e');
      rethrow;
    }
  }

  /// Get all archived classes for a teacher
  Future<List<StudentClass>> getArchivedClasses(String teacherId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$apiBase/api/teachers/$teacherId/classes/archived'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final classes = (data['classes'] as List)
            .map((c) => StudentClass.fromJson(c as Map<String, dynamic>))
            .toList();
        return classes;
      }
      return [];
    } catch (e) {
      debugPrint('Error getting archived classes: $e');
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    httpClient.close();
  }
}
