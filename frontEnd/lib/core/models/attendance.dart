// filepath: c:\Users\abdulazeezbrhomi\OneDrive\University\Epi\Sem3\flutter\epiApp\lib\core\models\attendance.dart
// ============================================================================
// ATTENDANCE MODEL - Represents attendance records
// ============================================================================

import 'package:flutter/material.dart';

enum AttendanceStatus {
  present,
  absent,
  excused,
  late,
}

class AttendanceRecord {
  final String id;
  final DateTime date;
  final String day;
  final int timeSlot;
  final AttendanceStatus status;
  final String? notes;
  final String? markedBy;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.day,
    required this.timeSlot,
    required this.status,
    this.notes,
    this.markedBy,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    print('🔍 AttendanceRecord.fromJson: Parsing record...');
    print('🔍 AttendanceRecord.fromJson: id = ${json['id']}');
    print('🔍 AttendanceRecord.fromJson: date = ${json['date']}');
    print('🔍 AttendanceRecord.fromJson: day = ${json['day']}');
    print('🔍 AttendanceRecord.fromJson: time_slot = ${json['time_slot']}');
    print('🔍 AttendanceRecord.fromJson: status = ${json['status']}');
    print('🔍 AttendanceRecord.fromJson: notes = ${json['notes']}');
    print('🔍 AttendanceRecord.fromJson: marked_by = ${json['marked_by']}');
    
    return AttendanceRecord(
      id: json['id'].toString(), // Convert int to string
      date: DateTime.parse(json['date'] as String),
      day: json['day'] as String,
      timeSlot: json['time_slot'] as int,
      status: _parseStatus(json['status'] as String),
      notes: json['notes'] as String?,
      markedBy: json['marked_by'] as String?,
    );
  }

  static AttendanceStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'excused':
        return AttendanceStatus.excused;
      case 'late':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus.absent;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'day': day,
      'time_slot': timeSlot,
      'status': status.toString().split('.').last,
      'notes': notes,
      'marked_by': markedBy,
    };
  }

  String get statusDisplay {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.excused:
        return 'Excused';
      case AttendanceStatus.late:
        return 'Late';
    }
  }

  Color get statusColor {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.excused:
        return Colors.orange;
      case AttendanceStatus.late:
        return Colors.yellow;
    }
  }
}

class AttendanceSummary {
  final String courseId;
  final String courseCode;
  final String courseName;
  final int totalSessions;
  final int presentCount;
  final int absentCount;
  final int excusedCount;
  final int lateCount;
  final double attendancePercentage;

  AttendanceSummary({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.totalSessions,
    required this.presentCount,
    required this.absentCount,
    required this.excusedCount,
    required this.lateCount,
    required this.attendancePercentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    print('🔍 AttendanceSummary.fromJson: Parsing summary...');
    print('🔍 AttendanceSummary.fromJson: courseId = ${json['courseId']}');
    print('🔍 AttendanceSummary.fromJson: courseCode = ${json['courseCode']}');
    print('🔍 AttendanceSummary.fromJson: courseName = ${json['courseName']}');
    print('🔍 AttendanceSummary.fromJson: totalSessions = ${json['totalSessions']}');
    print('🔍 AttendanceSummary.fromJson: presentCount = ${json['presentCount']}');
    print('🔍 AttendanceSummary.fromJson: absentCount = ${json['absentCount']}');
    print('🔍 AttendanceSummary.fromJson: excusedCount = ${json['excusedCount']}');
    print('🔍 AttendanceSummary.fromJson: lateCount = ${json['lateCount']}');
    print('🔍 AttendanceSummary.fromJson: attendancePercentage = ${json['attendancePercentage']}');
    
    return AttendanceSummary(
      courseId: json['courseId'] as String,
      courseCode: json['courseCode'] as String,
      courseName: json['courseName'] as String,
      totalSessions: json['totalSessions'] as int,
      presentCount: json['presentCount'] as int,
      absentCount: json['absentCount'] as int,
      excusedCount: json['excusedCount'] as int,
      lateCount: json['lateCount'] as int,
      attendancePercentage: (json['attendancePercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseCode': courseCode,
      'courseName': courseName,
      'totalSessions': totalSessions,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'excusedCount': excusedCount,
      'lateCount': lateCount,
      'attendancePercentage': attendancePercentage,
    };
  }
}
