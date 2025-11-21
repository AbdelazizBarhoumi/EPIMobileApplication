// ============================================================================
// GRADE SERVICE - Handles all grade/transcript related API calls
// ============================================================================

import '../api_client.dart';
import '../models/grade.dart';

class GradeService {
  final ApiClient apiClient;

  GradeService(this.apiClient);

  /// Get full transcript for a student across all years
  Future<Transcript> getFullTranscript(int studentId) async {
    try {
      final response = await apiClient.get('/api/grades/student/$studentId/transcript');
      return Transcript.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load transcript: $e');
    }
  }

  /// Get transcript for a specific year
  Future<YearTranscript> getTranscriptByYear(int studentId, int year) async {
    try {
      final response = await apiClient.get('/api/grades/student/$studentId/transcript/year/$year');
      return YearTranscript.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to load year transcript: $e');
    }
  }

  /// Get current semester grades
  Future<SemesterTranscript> getCurrentSemester(int studentId) async {
    try {
      final response = await apiClient.get('/api/grades/student/$studentId/current-semester');
      return SemesterTranscript.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to load current semester grades: $e');
    }
  }

  /// Get GPA statistics
  Future<Map<String, dynamic>> getGpaStats(int studentId) async {
    try {
      final response = await apiClient.get('/api/grades/student/$studentId/gpa');
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load GPA stats: $e');
    }
  }

  /// Update grades for a specific course (admin function, may not be needed)
  Future<void> updateGrades(int studentId, int courseId, {
    double? ccScore,
    double? dsScore,
    double? examScore,
    String? status,
  }) async {
    try {
      await apiClient.put('/api/grades/student/$studentId/course/$courseId', {
        if (ccScore != null) 'cc_score': ccScore,
        if (dsScore != null) 'ds_score': dsScore,
        if (examScore != null) 'exam_score': examScore,
        if (status != null) 'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update grades: $e');
    }
  }
}
