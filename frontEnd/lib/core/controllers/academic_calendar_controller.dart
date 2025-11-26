// ============================================================================
// ACADEMIC CALENDAR CONTROLLER - Manages academic calendar state
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/academic_calendar.dart';
import '../services/academic_calendar_service.dart';

enum AcademicCalendarLoadingState { initial, loading, loaded, error }

class AcademicCalendarController extends ChangeNotifier {
  final AcademicCalendarService _calendarService;

  AcademicCalendarController(this._calendarService);

  AcademicCalendarLoadingState _state = AcademicCalendarLoadingState.initial;
  List<AcademicCalendar> _calendars = [];
  AcademicCalendar? _activeCalendar;
  String? _errorMessage;

  AcademicCalendarLoadingState get state => _state;
  List<AcademicCalendar> get calendars => _calendars;
  AcademicCalendar? get activeCalendar => _activeCalendar;
  String? get errorMessage => _errorMessage;

  /// Load all academic calendars
  Future<void> loadCalendars() async {
    _state = AcademicCalendarLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _calendars = await _calendarService.getAllCalendars();
      _state = AcademicCalendarLoadingState.loaded;
      debugPrint('AcademicCalendarController: Loaded ${_calendars.length} calendars');
    } catch (e) {
      _state = AcademicCalendarLoadingState.error;
      _errorMessage = e.toString();
      debugPrint('AcademicCalendarController: Error loading calendars: $e');
    }
    notifyListeners();
  }

  /// Load active calendar
  Future<void> loadActiveCalendar() async {
    try {
      _activeCalendar = await _calendarService.getActiveCalendar();
      debugPrint('AcademicCalendarController: Active calendar: ${_activeCalendar?.name ?? 'None'}');
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('AcademicCalendarController: Error loading active calendar: $e');
      notifyListeners();
    }
  }

  /// Load calendars for specific year
  Future<void> loadCalendarsByYear(int year) async {
    _state = AcademicCalendarLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _calendars = await _calendarService.getCalendarsByYear(year);
      _state = AcademicCalendarLoadingState.loaded;
      debugPrint('AcademicCalendarController: Loaded ${_calendars.length} calendars for year $year');
    } catch (e) {
      _state = AcademicCalendarLoadingState.error;
      _errorMessage = e.toString();
      debugPrint('AcademicCalendarController: Error loading calendars for year $year: $e');
    }
    notifyListeners();
  }

  /// Get calendar by ID
  AcademicCalendar? getCalendarById(int id) {
    try {
      return _calendars.firstWhere((calendar) => calendar.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get calendars by status
  List<AcademicCalendar> getCalendarsByStatus(String status) {
    return _calendars.where((calendar) => calendar.status == status).toList();
  }

  /// Get upcoming calendars
  List<AcademicCalendar> get upcomingCalendars => getCalendarsByStatus('upcoming');

  /// Get past calendars
  List<AcademicCalendar> get pastCalendars => getCalendarsByStatus('past');

  /// Get active calendar
  AcademicCalendar? get activeCalendarFromList => getCalendarsByStatus('active').firstOrNull;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}