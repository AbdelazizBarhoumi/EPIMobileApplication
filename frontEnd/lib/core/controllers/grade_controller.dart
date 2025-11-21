// ============================================================================
// GRADE CONTROLLER - Manages grade/transcript state
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/grade.dart';
import '../services/grade_service.dart';

enum GradeLoadingState { initial, loading, loaded, error }

class GradeController extends ChangeNotifier {
  final GradeService _gradeService;

  GradeController(this._gradeService);

  GradeLoadingState _state = GradeLoadingState.initial;
  Transcript? _transcript;
  SemesterTranscript? _currentSemester;
  Map<String, dynamic>? _gpaStats;
  String? _errorMessage;

  GradeLoadingState get state => _state;
  Transcript? get transcript => _transcript;
  SemesterTranscript? get currentSemester => _currentSemester;
  Map<String, dynamic>? get gpaStats => _gpaStats;
  String? get errorMessage => _errorMessage;

  /// Load full transcript
  Future<void> loadTranscript(int studentId) async {
    _state = GradeLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _transcript = await _gradeService.getFullTranscript(studentId);
      _state = GradeLoadingState.loaded;
    } catch (e) {
      _state = GradeLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Load current semester grades
  Future<void> loadCurrentSemester(int studentId) async {
    try {
      _currentSemester = await _gradeService.getCurrentSemester(studentId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Load GPA statistics
  Future<void> loadGpaStats(int studentId) async {
    try {
      _gpaStats = await _gradeService.getGpaStats(studentId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Get grades for a specific year
  YearTranscript? getYearTranscript(int year) {
    return _transcript?.transcript.firstWhere(
      (yt) => yt.year == year,
      orElse: () => YearTranscript(year: year, semesters: []),
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
