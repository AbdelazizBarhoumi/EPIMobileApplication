// ============================================================================
// COURSE MODEL - Represents a university course
// ============================================================================

import 'package:flutter/foundation.dart';

class Course {
  final int id;
  final String courseCode;
  final String name;
  final String? description;
  final int credits;
  final String? instructor;
  final String? schedule;
  final String? room;
  final int? academicCalendarId;
  
  // Grade components (if student is enrolled)
  final double? ccScore;
  final double? dsScore;
  final double? examScore;
  final double? finalGrade;
  final String? letterGrade;
  final String? status;
  
  // Enrollment info
  final int? programCourseId;
  final int? yearTaken;
  final int? semesterTaken;

  Course({
    required this.id,
    required this.courseCode,
    required this.name,
    this.description,
    required this.credits,
    this.instructor,
    this.schedule,
    this.room,
    this.academicCalendarId,
    this.ccScore,
    this.dsScore,
    this.examScore,
    this.finalGrade,
    this.letterGrade,
    this.status,
    this.programCourseId,
    this.yearTaken,
    this.semesterTaken,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Handle nested grades structure from API
    final grades = json['grades'] as Map<String, dynamic>?;
    
    debugPrint('Course.fromJson: Parsing course ${json['course_code']} - grades present: ${grades != null}');
    if (grades != null) {
      debugPrint('Course.fromJson: Grades data - cc: ${grades['cc_score']}, ds: ${grades['ds_score']}, exam: ${grades['exam_score']}, final: ${grades['final_grade']}, letter: ${grades['letter_grade']}');
    }
    
    return Course(
      id: json['id'] as int,
      courseCode: json['course_code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      credits: json['credits'] as int,
      instructor: json['instructor'] as String?,
      schedule: json['schedule'] as String?,
      room: json['room'] as String?,
      academicCalendarId: json['academic_calendar_id'] as int?,
      ccScore: grades != null && grades['cc_score'] != null ? _parseDouble(grades['cc_score']) : null,
      dsScore: grades != null && grades['ds_score'] != null ? _parseDouble(grades['ds_score']) : null,
      examScore: grades != null && grades['exam_score'] != null ? _parseDouble(grades['exam_score']) : null,
      finalGrade: grades != null && grades['final_grade'] != null ? _parseDouble(grades['final_grade']) : null,
      letterGrade: grades != null ? grades['letter_grade'] as String? : null,
      status: json['status'] as String?,
      programCourseId: json['program_course_id'] as int?,
      yearTaken: json['year_taken'] as int?,
      semesterTaken: json['semester_taken'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_code': courseCode,
      'name': name,
      'description': description,
      'credits': credits,
      'instructor': instructor,
      'schedule': schedule,
      'room': room,
      'academic_calendar_id': academicCalendarId,
      'cc_score': ccScore,
      'ds_score': dsScore,
      'exam_score': examScore,
      'final_grade': finalGrade,
      'letter_grade': letterGrade,
      'status': status,
      'program_course_id': programCourseId,
      'year_taken': yearTaken,
      'semester_taken': semesterTaken,
    };
  }
  
  bool get isEnrolled => status != null;
  bool get isCompleted => status == 'completed';
  
  // Check if all score components are available
  bool get hasAllScores => ccScore != null && dsScore != null && examScore != null;
  
  // Default weights if not provided
  int get ccWeight => 30;
  int get dsWeight => 20;
  int get examWeight => 40;
  
  // Helper method to safely parse double values that might be strings
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
