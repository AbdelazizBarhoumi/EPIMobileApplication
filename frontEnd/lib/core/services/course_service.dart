// ============================================================================
// COURSE SERVICE - Handles all course related API calls
// ============================================================================

import '../api_client.dart';
import '../models/course.dart';

class CourseService {
  final ApiClient apiClient;

  CourseService(this.apiClient);

  /// Get all courses for the authenticated student
  Future<List<Course>> getStudentCourses() async {
    print('📚 CourseService: Fetching student courses from API...');
    try {
      final response = await apiClient.get('/api/student/courses');
      print('📚 CourseService: Response received');
      final courses = response['data'] as List;
      print('📚 CourseService: Parsing ${courses.length} courses...');
      final courseList = courses.map((course) => Course.fromJson(course as Map<String, dynamic>)).toList();
      print('📚 CourseService: Courses parsed successfully');
      return courseList;
    } catch (e) {
      print('📚 CourseService: ERROR: $e');
      throw Exception('Failed to load student courses: $e');
    }
  }

  /// Get all available courses
  Future<List<Course>> getAllCourses() async {
    try {
      final response = await apiClient.get('/api/courses');
      final courses = response['data'] as List;
      return courses.map((course) => Course.fromJson(course as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  /// Get course details by ID
  Future<Course> getCourseById(int id) async {
    try {
      final response = await apiClient.get('/api/courses/$id');
      return Course.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load course details: $e');
    }
  }

  /// Get course schedule
  Future<Map<String, dynamic>> getCourseSchedule() async {
    try {
      final response = await apiClient.get('/api/courses/schedule');
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load course schedule: $e');
    }
  }
}
