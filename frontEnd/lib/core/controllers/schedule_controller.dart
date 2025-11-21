// ============================================================================
// SCHEDULE CONTROLLER - Manages schedule state
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';

enum ScheduleLoadingState { initial, loading, loaded, error }

class ScheduleController extends ChangeNotifier {
  final ScheduleService _scheduleService;

  ScheduleController(this._scheduleService);

  ScheduleLoadingState _state = ScheduleLoadingState.initial;
  WeeklySchedule? _schedule;
  String? _errorMessage;

  ScheduleLoadingState get state => _state;
  WeeklySchedule? get schedule => _schedule;
  String? get errorMessage => _errorMessage;

  /// Load student's weekly schedule
  Future<void> loadMySchedule() async {
    print('📅 ScheduleController: Loading my schedule...');
    _state = ScheduleLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _schedule = await _scheduleService.getMySchedule();
      print('📅 ScheduleController: Schedule loaded');
      print('📅 ScheduleController: Days with classes: ${_schedule?.schedule.keys.join(", ")}');
      int totalSessions = _schedule?.schedule.values.fold<int>(0, (sum, sessions) => sum + sessions.length) ?? 0;
      print('📅 ScheduleController: Total sessions: $totalSessions');
      _state = ScheduleLoadingState.loaded;
    } catch (e) {
      print('📅 ScheduleController: ERROR loading schedule: $e');
      _state = ScheduleLoadingState.error;
      _errorMessage = e.toString();
      rethrow;
    }
    notifyListeners();
  }

  /// Load schedule for specific major/year/semester
  Future<void> loadScheduleByMajor(int majorId, int year, int semester) async {
    _state = ScheduleLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _schedule = await _scheduleService.getScheduleByMajor(majorId, year, semester);
      _state = ScheduleLoadingState.loaded;
    } catch (e) {
      _state = ScheduleLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Get sessions for a specific day
  List<ScheduleSession> getSessionsForDay(String day) {
    return _schedule?.getSessionsForDay(day) ?? [];
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
