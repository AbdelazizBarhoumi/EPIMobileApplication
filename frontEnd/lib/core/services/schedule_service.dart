// ============================================================================
// SCHEDULE SERVICE - Handles schedule related API calls
// ============================================================================

import '../api_client.dart';
import '../models/schedule.dart';

class ScheduleService {
  final ApiClient apiClient;

  ScheduleService(this.apiClient);

  /// Get weekly schedule for authenticated student
  Future<WeeklySchedule> getMySchedule() async {
    print('📅 ScheduleService: Fetching schedule from API...');
    try {
      final response = await apiClient.get('/api/schedule/my-schedule');
      print('📅 ScheduleService: Response received');
      print('📅 ScheduleService: Data keys: ${(response['data'] as Map).keys}');
      final schedule = WeeklySchedule.fromJson(response['data']['schedule'] as Map<String, dynamic>);
      print('📅 ScheduleService: Schedule parsed successfully');
      return schedule;
    } catch (e) {
      print('📅 ScheduleService: ERROR: $e');
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
