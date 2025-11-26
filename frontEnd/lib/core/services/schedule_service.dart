// ============================================================================
// SCHEDULE SERVICE - Handles schedule related API calls
// ============================================================================

import 'package:flutter/foundation.dart';
import '../api_client.dart';
import '../models/schedule.dart';

class ScheduleService {
  final ApiClient apiClient;

  ScheduleService(this.apiClient);

  /// Get weekly schedule for authenticated student
  Future<WeeklySchedule> getMySchedule() async {
    debugPrint('📅 ScheduleService: getMySchedule called');
    try {
      debugPrint('📅 ScheduleService: Making API call to /api/schedule/my-schedule');
      final response = await apiClient.get('/api/schedule/my-schedule');
      debugPrint('📅 ScheduleService: API response received');
      debugPrint('📅 ScheduleService: Response status: ${response['success']}');
      debugPrint('📅 ScheduleService: Response data keys: ${(response['data'] as Map?)?.keys ?? "null"}');
      if (response['data'] != null && response['data']['schedule'] != null) {
        debugPrint('📅 ScheduleService: Parsing schedule from response');
        final schedule = WeeklySchedule.fromJson(response['data']['schedule'] as Map<String, dynamic>);
        debugPrint('📅 ScheduleService: Schedule parsed successfully');
        debugPrint('📅 ScheduleService: Schedule has days: ${schedule.schedule.keys}');
        return schedule;
      } else {
        debugPrint('📅 ScheduleService: No schedule data in response');
        throw Exception('No schedule data received');
      }
    } catch (e) {
      debugPrint('📅 ScheduleService: ERROR in getMySchedule: $e');
      throw Exception('Failed to load schedule: $e');
    }
  }

  /// Get schedule for a specific major, year, and semester
  Future<WeeklySchedule> getScheduleByMajor(int majorId, int year, int semester) async {
    try {
      final response = await apiClient.get('/api/schedule/major/$majorId/year/$year/semester/$semester');
      return WeeklySchedule.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load major schedule: $e');
    }
  }
}
