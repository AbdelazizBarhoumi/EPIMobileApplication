// filepath: c:\Users\abdulazeezbrhomi\OneDrive\University\Epi\Sem3\flutter\epiApp\lib\core\repositories\student_repository.dart
import '../models/student.dart';
import '../models/course.dart';
import 'base_repository.dart';

class StudentRepository extends BaseRepository {
  StudentRepository(super.apiClient);

  @override
  String get resourcePath => '/api/students';

  Future<Student> getProfile() async {
    final data = await apiClient.get('$resourcePath/profile');
    return Student.fromJson(data);
  }

  Future<Student> updateProfile(Map<String, dynamic> updates) async {
    final data = await apiClient.put('$resourcePath/profile', updates);
    return Student.fromJson(data);
  }

  Future<List<Course>> getCourses() async {
    final data = await apiClient.get('$resourcePath/courses');
    final courses = data['courses'] as List;
    return courses.map((json) => Course.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> getGrades() async {
    return await apiClient.get('$resourcePath/grades');
  }

  Future<Map<String, dynamic>> getAttendance() async {
    return await apiClient.get('$resourcePath/attendance');
  }

  Future<Map<String, dynamic>> getBills() async {
    return await apiClient.get('$resourcePath/bills');
  }

  Future<List<Map<String, dynamic>>> getSchedule() async {
    final data = await apiClient.get('$resourcePath/schedule');
    return List<Map<String, dynamic>>.from(data['schedule']);
  }
}
