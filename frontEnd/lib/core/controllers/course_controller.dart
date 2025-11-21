// ============================================================================
// COURSE CONTROLLER - Manages course state
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/course_service.dart';

enum CourseLoadingState { initial, loading, loaded, error }

class CourseController extends ChangeNotifier {
  final CourseService _courseService;

  CourseController(this._courseService);

  CourseLoadingState _state = CourseLoadingState.initial;
  List<Course> _courses = [];
  Course? _selectedCourse;
  String? _errorMessage;

  CourseLoadingState get state => _state;
  List<Course> get courses => _courses;
  Course? get selectedCourse => _selectedCourse;
  String? get errorMessage => _errorMessage;

  /// Load student's enrolled courses
  Future<void> loadStudentCourses() async {
    print('📚 CourseController: Loading student courses...');
    _state = CourseLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _courseService.getStudentCourses();
      print('📚 CourseController: Courses loaded - Count: ${_courses.length}');
      for (var course in _courses) {
        print('📚   - ${course.courseCode}: ${course.name} (${course.credits} credits)');
      }
      _state = CourseLoadingState.loaded;
    } catch (e) {
      print('📚 CourseController: ERROR loading courses: $e');
      _state = CourseLoadingState.error;
      _errorMessage = e.toString();
      rethrow;
    }
    notifyListeners();
  }

  /// Load all available courses
  Future<void> loadAllCourses() async {
    _state = CourseLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _courseService.getAllCourses();
      _state = CourseLoadingState.loaded;
    } catch (e) {
      _state = CourseLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Load course details
  Future<void> loadCourseDetails(int courseId) async {
    try {
      _selectedCourse = await _courseService.getCourseById(courseId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
