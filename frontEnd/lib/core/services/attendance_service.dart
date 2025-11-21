// ============================================================================
// ATTENDANCE SERVICE - Handles attendance related API calls
// ============================================================================

import '../api_client.dart';
import '../models/attendance.dart';

class AttendanceService {
  final ApiClient apiClient;

  AttendanceService(this.apiClient);

  /// Get all attendance records for authenticated student
  /// Note: This endpoint returns summary data, not individual records
  /// Use getAttendanceSummary() for course-wise attendance data
  Future<List<AttendanceRecord>> getMyAttendance() async {
    print('🔍 AttendanceService: Calling getMyAttendance()...');
    print('🔍 AttendanceService: Note - This API returns summaries, not individual records');
    print('🔍 AttendanceService: Returning empty list - use getAttendanceSummary() instead');
    
    // The /api/attendance/my-attendance endpoint returns course summaries only
    // Individual attendance records are not available from this endpoint
    // The absences page uses getAttendanceSummary() which works correctly
    return [];
  }

  /// Get attendance records for a specific course
  Future<List<AttendanceRecord>> getCourseAttendance(int courseId) async {
    try {
      print('🔍 AttendanceService: Calling getCourseAttendance() for course ID: $courseId');
      final response = await apiClient.get('/api/attendance/course/$courseId');
      final data = response['data'] as Map<String, dynamic>;
      final records = data['records'] as List;
      print('🔍 AttendanceService: Raw API response data: ${response['data']}');
      final parsedRecords = records.map((record) => AttendanceRecord.fromJson(record as Map<String, dynamic>)).toList();
      print('🔍 AttendanceService: Parsed ${parsedRecords.length} attendance records for course $courseId');
      for (int i = 0; i < parsedRecords.length; i++) {
        final record = parsedRecords[i];
        print('🔍 AttendanceService: Record ${i + 1}: Date=${record.date.toString().substring(0, 10)} (${record.day}), Status=${record.statusDisplay}, Notes=${record.notes}');
      }
      return parsedRecords;
    } catch (e) {
      print('🔍 AttendanceService: ERROR in getCourseAttendance: $e');
      throw Exception('Failed to load course attendance: $e');
    }
  }

  /// Get attendance summary by course
  Future<List<AttendanceSummary>> getAttendanceSummary() async {
    print('🔍 AttendanceService: Calling getAttendanceSummary()...');
    try {
      final response = await apiClient.get('/api/attendance/my-attendance');
      print('🔍 AttendanceService: Summary API response received');
      
      final data = response['data'] as Map<String, dynamic>;
      final courses = data['courses'] as List;
      print('🔍 AttendanceService: Processing ${courses.length} courses for summary');
      print('🔍 AttendanceService: Full data keys: ${data.keys.toList()}');
      print('🔍 AttendanceService: Overall data: ${data['overall']}');
      
      final summaries = <AttendanceSummary>[];
      
      for (var courseData in courses) {
        print('🔍 AttendanceService: Full courseData: $courseData');
        final course = courseData['course'] as Map<String, dynamic>;
        final attendance = courseData['attendance'] as Map<String, dynamic>;
        
        print('🔍 AttendanceService: Course ${course['code']} - ${course['name']}: attendance keys = ${attendance.keys.toList()}');
        print('🔍 AttendanceService: Full attendance map: $attendance');
        print('🔍 AttendanceService: Raw attendance data: total=${attendance['total']}, present=${attendance['present']}, percentage=${attendance['percentage']}');
        
        // Convert values with explicit type handling
        final total = (attendance['total'] as num?)?.toInt() ?? 0;
        final present = (attendance['present'] as num?)?.toInt() ?? 0;
        final percentage = (attendance['percentage'] as num?)?.toDouble() ?? 0.0;
        final absent = total - present;
        
        print('🔍 AttendanceService: Converted values: total=$total, present=$present, absent=$absent, percentage=$percentage');
        
        final summary = AttendanceSummary(
          courseId: course['id'].toString(),
          courseCode: course['code'],
          courseName: course['name'],
          totalSessions: total,
          presentCount: present,
          absentCount: absent,
          excusedCount: 0, // Not provided by backend
          lateCount: 0, // Not provided by backend
          attendancePercentage: percentage,
        );
        
        print('🔍 AttendanceService: Course ${course['code']}: ${summary.presentCount} present, ${summary.absentCount} absent, ${summary.totalSessions} total, ${summary.attendancePercentage.toStringAsFixed(1)}%');
        
        summaries.add(summary);
      }
      
      print('🔍 AttendanceService: Generated ${summaries.length} attendance summaries');
      return summaries;
    } catch (e) {
      print('🔍 AttendanceService: ERROR in getAttendanceSummary: $e');
      throw Exception('Failed to load attendance summary: $e');
    }
  }
}
