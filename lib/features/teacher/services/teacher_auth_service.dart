import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/teacher_account.dart';

/// Service for teacher authentication via Cloudflare Workers API
/// All teacher data stored in D1 (SQLite) database
class TeacherAuthService {
  final String apiBase; // Live: https://brightbound-api.matt-hurley91.workers.dev
  final http.Client httpClient;

  TeacherAuthService({
    String? apiBase,
    http.Client? httpClient,
  })  : apiBase = apiBase ?? 'https://brightbound-api.matt-hurley91.workers.dev',
        httpClient = httpClient ?? http.Client();

  /// Current teacher ID (stored locally after login)
  String? _currentTeacherId;
  String? _authToken;

  /// Get current authenticated teacher ID
  String? get currentTeacherId => _currentTeacherId;

  /// Register a new teacher account
  /// Returns TeacherAccount if successful, null if registration fails
  Future<TeacherAccount?> registerTeacher({
    required String email,
    required String password,
    required String fullName,
    required String schoolName,
    String? phoneNumber,
    String? schoolDistrict,
    String? gradeSpecialty,
  }) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$apiBase/api/teachers/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'schoolName': schoolName,
          'phoneNumber': phoneNumber,
          'schoolDistrict': schoolDistrict,
          'gradeSpecialty': gradeSpecialty,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final account = TeacherAccount.fromJson(data['teacher']);
        _currentTeacherId = account.id;
        _authToken = data['token'] as String?;
        return account;
      } else if (response.statusCode == 409) {
        throw Exception('Email already registered');
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  /// Login teacher with email and password
  /// Returns TeacherAccount if successful
  Future<TeacherAccount?> loginTeacher({
    required String email,
    required String password,
  }) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$apiBase/api/teachers/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final account = TeacherAccount.fromJson(data['teacher']);
        final token = data['token'] as String?;

        _currentTeacherId = account.id;
        _authToken = token;

        return account;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  /// Get current teacher account
  Future<TeacherAccount?> getCurrentTeacher() async {
    try {
      if (_currentTeacherId == null || _authToken == null) return null;

      final response = await httpClient.get(
        Uri.parse('$apiBase/api/teachers/$_currentTeacherId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return TeacherAccount.fromJson(data['teacher']);
      } else if (response.statusCode == 401) {
        _currentTeacherId = null;
        _authToken = null;
        throw Exception('Unauthorized - please login again');
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current teacher: $e');
      return null;
    }
  }

  /// Update teacher profile
  Future<TeacherAccount?> updateTeacherProfile({
    required String teacherId,
    String? fullName,
    String? phoneNumber,
    String? schoolDistrict,
    String? gradeSpecialty,
  }) async {
    try {
      if (_authToken == null) throw Exception('Not authenticated');

      final body = <String, dynamic>{};
      if (fullName != null) body['fullName'] = fullName;
      if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
      if (schoolDistrict != null) body['schoolDistrict'] = schoolDistrict;
      if (gradeSpecialty != null) body['gradeSpecialty'] = gradeSpecialty;

      final response = await httpClient.patch(
        Uri.parse('$apiBase/api/teachers/$teacherId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return TeacherAccount.fromJson(data['teacher']);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      return null;
    } catch (e) {
      debugPrint('Error updating teacher profile: $e');
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword({
    required String teacherId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_authToken == null) throw Exception('Not authenticated');

      final response = await httpClient.post(
        Uri.parse('$apiBase/api/teachers/$teacherId/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      rethrow;
    }
  }

  /// Request password reset email
  Future<void> resetPasswordRequest(String email) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$apiBase/api/teachers/reset-password-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send reset email');
      }
    } catch (e) {
      debugPrint('Error requesting password reset: $e');
      rethrow;
    }
  }

  /// Upgrade teacher license
  Future<TeacherAccount?> upgradeLicense({
    required String teacherId,
    required String newLicenseType,
    String? stripePaymentIntentId,
  }) async {
    try {
      if (_authToken == null) throw Exception('Not authenticated');

      final response = await httpClient.post(
        Uri.parse('$apiBase/api/teachers/$teacherId/upgrade-license'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'licenseType': newLicenseType,
          'stripePaymentIntentId': stripePaymentIntentId,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return TeacherAccount.fromJson(data['teacher']);
      } else if (response.statusCode == 402) {
        throw Exception('Payment required');
      }
      return null;
    } catch (e) {
      debugPrint('Error upgrading license: $e');
      rethrow;
    }
  }

  /// Logout (clear local state)
  Future<void> logout() async {
    try {
      _currentTeacherId = null;
      _authToken = null;
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    httpClient.close();
  }
}
