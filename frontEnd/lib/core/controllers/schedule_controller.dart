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
    debugPrint('📅 ScheduleController: loadMySchedule called');
    _state = ScheduleLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📅 ScheduleController: Calling _scheduleService.getMySchedule()');
      _schedule = await _scheduleService.getMySchedule();
      debugPrint('📅 ScheduleController: Schedule loaded successfully');
      if (_schedule != null) {
        debugPrint('📅 ScheduleController: Schedule days: ${_schedule!.schedule.keys}');
        _schedule!.schedule.forEach((day, sessions) {
          debugPrint('📅 ScheduleController: $day has ${sessions.length} sessions');
          sessions.forEach((session) {
            debugPrint('📅 ScheduleController:   - ${session.courseName} (${session.startTime}-${session.endTime}) in ${session.room}');
          });
        });
        int totalSessions = _schedule!.schedule.values.fold<int>(0, (sum, sessions) => sum + sessions.length);
        debugPrint('📅 ScheduleController: Total sessions across all days: $totalSessions');
      } else {
        debugPrint('📅 ScheduleController: Schedule is null');
      }
      _state = ScheduleLoadingState.loaded;
      debugPrint('📅 ScheduleController: State set to loaded');
    } catch (e) {
      debugPrint('📅 ScheduleController: ERROR loading schedule: $e');
      _state = ScheduleLoadingState.error;
      _errorMessage = e.toString();
      rethrow;
    }
    notifyListeners();
    debugPrint('📅 ScheduleController: Notified listeners');
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
