// ============================================================================
// STUDENT SERVICE - Handles student profile and dashboard API calls
// ============================================================================

import '../api_client.dart';
import '../models/student.dart';

class StudentService {
  final ApiClient apiClient;

  StudentService(this.apiClient);

  /// Get student profile
  Future<Student> getProfile() async {
    try {
      print('🔍 StudentService: Calling API...');
      final response = await apiClient.get('/api/student/profile');
      print('🔍 StudentService: Response keys: ${response.keys}');
      print('🔍 StudentService: Data keys: ${(response['data'] as Map).keys}');
      
      // Backend returns: { success: true, data: { student: {...}, attendance_percentage: ..., outstanding_balance: ... } }
      // We need to extract the 'student' object from 'data'
      final data = response['data'] as Map<String, dynamic>;
      final studentData = data['student'] as Map<String, dynamic>;
      
      print('🔍 StudentService: Student data keys: ${studentData.keys}');
      print('🔍 StudentService: Parsing Student.fromJson...');
      
      final student = Student.fromJson(studentData);
      print('🔍 StudentService: ✅ Student parsed successfully');
      return student;
    } catch (e) {
      print('🔍 StudentService: ❌ Error: $e');
      throw Exception('Failed to load profile: $e');
    }
  }

  /// Get dashboard data
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await apiClient.get('/api/student/dashboard');
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }

  /// Get student courses
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await apiClient.get('/api/student/courses');
      return List<Map<String, dynamic>>.from(response['data'] as List);
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  /// Get student attendance
  Future<Map<String, dynamic>> getAttendance() async {
    try {
      final response = await apiClient.get('/api/student/attendance');
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }
}
