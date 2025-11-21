// ============================================================================
// MAJOR SERVICE - Handles major/program related API calls
// ============================================================================

import '../api_client.dart';
import '../models/student.dart';

class MajorService {
  final ApiClient apiClient;

  MajorService(this.apiClient);

  /// Get all majors
  Future<List<Major>> getAllMajors() async {
    try {
      final response = await apiClient.get('/api/majors');
      final majors = response['data'] as List;
      return majors.map((major) => Major.fromJson(major as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load majors: $e');
    }
  }

  /// Get major details by ID
  Future<Major> getMajorById(int id) async {
    try {
      final response = await apiClient.get('/api/majors/$id');
      return Major.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load major details: $e');
    }
  }

  /// Get major curriculum
  Future<Map<String, dynamic>> getMajorCurriculum(int majorId) async {
    try {
      final response = await apiClient.get('/api/majors/$majorId/curriculum');
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load major curriculum: $e');
    }
  }

  /// Get courses by year
  Future<List<Map<String, dynamic>>> getCoursesByYear(int majorId, int year) async {
    try {
      final response = await apiClient.get('/api/majors/$majorId/year/$year');
      return List<Map<String, dynamic>>.from(response['data'] as List);
    } catch (e) {
      throw Exception('Failed to load courses by year: $e');
    }
  }

  /// Get courses by year and semester
  Future<List<Map<String, dynamic>>> getCoursesByYearAndSemester(int majorId, int year, int semester) async {
    try {
      final response = await apiClient.get('/api/majors/$majorId/year/$year/semester/$semester');
      return List<Map<String, dynamic>>.from(response['data'] as List);
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }
}
