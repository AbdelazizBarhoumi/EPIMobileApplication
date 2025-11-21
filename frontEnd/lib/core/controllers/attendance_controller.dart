// ============================================================================
// ATTENDANCE CONTROLLER - Manages attendance state
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

enum AttendanceLoadingState { initial, loading, loaded, error }

class AttendanceController extends ChangeNotifier {
  final AttendanceService _attendanceService;

  AttendanceController(this._attendanceService);

  // Expose attendance service for detail fetching
  AttendanceService get attendanceService => _attendanceService;

  AttendanceLoadingState _state = AttendanceLoadingState.initial;
  List<AttendanceRecord> _records = [];
  List<AttendanceSummary> _summaries = [];
  String? _errorMessage;

  AttendanceLoadingState get state => _state;
  List<AttendanceRecord> get records => _records;
  List<AttendanceSummary> get summaries => _summaries;
  String? get errorMessage => _errorMessage;

  /// Load all attendance records
  Future<void> loadAttendance() async {
    _state = AttendanceLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _records = await _attendanceService.getMyAttendance();
      _state = AttendanceLoadingState.loaded;
    } catch (e) {
      _state = AttendanceLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Load attendance summary
  Future<void> loadSummary() async {
    try {
      _summaries = await _attendanceService.getAttendanceSummary();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Load attendance for specific course
  Future<void> loadCourseAttendance(int courseId) async {
    try {
      _records = await _attendanceService.getCourseAttendance(courseId);
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
