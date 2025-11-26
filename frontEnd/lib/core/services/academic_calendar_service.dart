// ============================================================================
// ACADEMIC CALENDAR SERVICE - Handles academic calendar API calls
// ============================================================================

import 'package:flutter/foundation.dart';
import '../api_client.dart';
import '../models/academic_calendar.dart';

class AcademicCalendarService {
  final ApiClient apiClient;

  AcademicCalendarService(this.apiClient);

  /// Get all academic calendars
  Future<List<AcademicCalendar>> getAllCalendars() async {
    try {
      final response = await apiClient.get('/api/academic-calendars');
      final data = response['data'] as List<dynamic>;
      return data.map((json) => AcademicCalendar.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load academic calendars: $e');
    }
  }

  /// Get active academic calendar
  Future<AcademicCalendar?> getActiveCalendar() async {
    try {
      final response = await apiClient.get('/api/academic-calendars/active');
      if (response['data'] == null) return null;
      return AcademicCalendar.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load active calendar: $e');
    }
  }

  /// Get academic calendar by year
  Future<List<AcademicCalendar>> getCalendarsByYear(int year) async {
    try {
      final response = await apiClient.get('/api/academic-calendars/year/$year');
      debugPrint('AcademicCalendarService: Raw response: $response');
      debugPrint('AcademicCalendarService: Response data type: ${response['data'].runtimeType}');
      debugPrint('AcademicCalendarService: Response data: ${response['data']}');

      final data = response['data'];
      if (data is List) {
        return data.map((json) => AcademicCalendar.fromJson(json as Map<String, dynamic>)).toList();
      } else if (data is Map) {
        // If it's a single calendar object, wrap it in a list
        debugPrint('AcademicCalendarService: Data is Map, wrapping in list');
        return [AcademicCalendar.fromJson(data as Map<String, dynamic>)];
      } else {
        throw Exception('Unexpected data type: ${data.runtimeType}');
      }
    } catch (e) {
      throw Exception('Failed to load calendars for year $year: $e');
    }
  }

  /// Get upcoming academic calendars
  Future<List<AcademicCalendar>> getUpcomingCalendars() async {
    try {
      final response = await apiClient.get('/api/academic-calendars/upcoming');
      final data = response['data'] as List<dynamic>;
      return data.map((json) => AcademicCalendar.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load upcoming calendars: $e');
    }
  }
}