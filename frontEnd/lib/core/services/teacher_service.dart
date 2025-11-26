// lib/core/services/teacher_service.dart
import 'package:flutter/foundation.dart';
import '../api_client.dart';

class OfficeHour {
  final String day;
  final String start;
  final String end;

  OfficeHour({
    required this.day,
    required this.start,
    required this.end,
  });

  factory OfficeHour.fromJson(Map<String, dynamic> json) {
    return OfficeHour(
      day: json['day'],
      start: json['start'],
      end: json['end'],
    );
  }
}

class Teacher {
  final int id;
  final String teacherId;
  final String name;
  final String email;
  final String? phone;
  final String? department;
  final String? title;
  final String? specialization;
  final String? officeLocation;
  final List<OfficeHour> officeHours;
  final List<TeacherCourse> courses;

  Teacher({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.email,
    this.phone,
    this.department,
    this.title,
    this.specialization,
    this.officeLocation,
    this.officeHours = const [],
    this.courses = const [],
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      teacherId: json['teacher_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      department: json['department'],
      title: json['title'],
      specialization: json['specialization'],
      officeLocation: json['office_location'],
      officeHours: (json['office_hours'] as List<dynamic>?)
          ?.map((h) => OfficeHour.fromJson(h))
          .toList() ?? [],
      courses: (json['courses'] as List<dynamic>?)
          ?.map((c) => TeacherCourse.fromJson(c))
          .toList() ?? [],
    );
  }

  String get displayTitle => title ?? 'Teacher';
  String get displayDepartment => department ?? 'Department';
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}

class TeacherCourse {
  final String code;
  final String name;
  final int credits;
  final int semester;

  TeacherCourse({
    required this.code,
    required this.name,
    required this.credits,
    required this.semester,
  });

  factory TeacherCourse.fromJson(Map<String, dynamic> json) {
    return TeacherCourse(
      code: json['code'],
      name: json['name'],
      credits: json['credits'],
      semester: json['semester'],
    );
  }
}

class TeacherService {
  final ApiClient apiClient;

  TeacherService(this.apiClient);

  /// Get all teachers for the current student's semester
  Future<List<Teacher>> getMyTeachers() async {
    try {
      debugPrint('📡 Fetching teachers from API...');
      final response = await apiClient.get('/api/teachers/my-teachers');
      debugPrint('📥 API Response: $response');
      
      if (response['success'] == true) {
        final teachersData = response['data']['teachers'] as List;
        debugPrint('👨‍🏫 Found ${teachersData.length} teachers');
        
        final teachers = teachersData
            .map((json) => Teacher.fromJson(json))
            .toList();
        return teachers;
      }
      
      throw Exception(response['message'] ?? 'Failed to fetch teachers');
    } catch (e) {
      debugPrint('❌ Teacher service error: $e');
      throw Exception('Error fetching teachers: $e');
    }
  }

  /// Get teacher details by ID
  Future<Teacher> getTeacher(int teacherId) async {
    try {
      final response = await apiClient.get('/api/teachers/$teacherId');
      
      if (response['success'] == true) {
        return Teacher.fromJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'Failed to fetch teacher details');
    } catch (e) {
      throw Exception('Error fetching teacher details: $e');
    }
  }
}
