// ============================================================================
// STUDENT CONTROLLER - Manages student profile state
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../services/student_service.dart';

enum StudentLoadingState { initial, loading, loaded, error }

class StudentController extends ChangeNotifier {
  final StudentService _studentService;

  StudentController(this._studentService);

  StudentLoadingState _state = StudentLoadingState.initial;
  Student? _student;
  Map<String, dynamic>? _dashboard;
  String? _errorMessage;

  StudentLoadingState get state => _state;
  Student? get student => _student;
  Map<String, dynamic>? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;

  /// Load student profile
  Future<void> loadProfile() async {
    print('👤 StudentController: Starting loadProfile()...');
    _state = StudentLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      print('👤 StudentController: Calling studentService.getProfile()...');
      _student = await _studentService.getProfile();
      print('👤 StudentController: Profile loaded successfully - ${_student?.name}');
      _state = StudentLoadingState.loaded;
    } catch (e) {
      print('👤 StudentController: ERROR loading profile: $e');
      _state = StudentLoadingState.error;
      _errorMessage = e.toString();
      rethrow;
    }
    notifyListeners();
  }

  /// Load dashboard data
  Future<void> loadDashboard() async {
    try {
      _dashboard = await _studentService.getDashboard();
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
