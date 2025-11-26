// ============================================================================
// ACADEMIC CALENDAR MODEL - Represents academic semesters and important dates
// ============================================================================

import 'package:flutter/material.dart';

class AcademicCalendar {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'upcoming', 'active', 'past'
  final int plannedCredits;
  final List<ImportantDate>? importantDates;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AcademicCalendar({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.plannedCredits,
    this.importantDates,
    this.createdAt,
    this.updatedAt,
  });

  factory AcademicCalendar.fromJson(Map<String, dynamic> json) {
    return AcademicCalendar(
      id: json['id'] as int,
      name: json['name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
      plannedCredits: json['planned_credits'] as int? ?? 0,
      importantDates: json['important_dates'] != null
          ? _parseImportantDates(json['important_dates'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'status': status,
      'planned_credits': plannedCredits,
      'important_dates': importantDates?.map((date) => date.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper function to parse important dates from API response
  static List<ImportantDate> _parseImportantDates(Map<String, dynamic> dates) {
    return dates.entries.map((entry) {
      String title = entry.key.replaceAll('_', ' ').replaceAllMapped(
        RegExp(r'\b\w'),
        (match) => match.group(0)!.toUpperCase(),
      );
      
      DateTime date;
      DateTime? endDate;
      
      if (entry.value is Map) {
        date = DateTime.parse(entry.value['start'] as String);
        endDate = DateTime.parse(entry.value['end'] as String);
      } else {
        date = DateTime.parse(entry.value as String);
      }
      
      return ImportantDate(
        title: title,
        date: date,
        endDate: endDate,
        type: _getDateType(entry.key),
      );
    }).toList();
  }

  // Helper to determine date type based on key
  static String _getDateType(String key) {
    if (key.contains('begin') || key.contains('start')) return 'academic';
    if (key.contains('exam') || key.contains('final') || key.contains('midterm')) return 'exam';
    if (key.contains('break') || key.contains('holiday')) return 'holiday';
    if (key.contains('deadline') || key.contains('drop')) return 'deadline';
    return 'academic';
  }

  // Computed properties
  bool get isActive => status == 'active';
  bool get isUpcoming => status == 'upcoming';
  bool get isPast => status == 'past';

  int get durationInDays => endDate.difference(startDate).inDays;
  int get durationInWeeks => (durationInDays / 7).ceil();

  String get season {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('fall') || lowerName.contains('autumn')) return 'Fall';
    if (lowerName.contains('spring')) return 'Spring';
    if (lowerName.contains('summer')) return 'Summer';
    if (lowerName.contains('winter')) return 'Winter';
    return 'Unknown';
  }

  String get year => name.split(' ').lastWhere((part) => RegExp(r'^\d{4}$').hasMatch(part), orElse: () => DateTime.now().year.toString());

  Color get statusColor {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'past':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color get seasonColor {
    switch (season.toLowerCase()) {
      case 'fall':
        return Colors.orange;
      case 'spring':
        return Colors.green;
      case 'summer':
        return Colors.yellow;
      case 'winter':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class ImportantDate {
  final String title;
  final DateTime date;
  final DateTime? endDate;
  final String type; // 'academic', 'exam', 'holiday', 'deadline', 'registration', 'event'
  final String? description;

  ImportantDate({
    required this.title,
    required this.date,
    this.endDate,
    required this.type,
    this.description,
  });

  factory ImportantDate.fromJson(Map<String, dynamic> json) {
    return ImportantDate(
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      type: json['type'] as String? ?? 'academic',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'type': type,
      'description': description,
    };
  }

  IconData get icon {
    switch (type) {
      case 'academic':
        return Icons.school;
      case 'exam':
        return Icons.assignment;
      case 'holiday':
        return Icons.celebration;
      case 'deadline':
        return Icons.edit;
      case 'registration':
        return Icons.app_registration;
      case 'event':
        return Icons.event;
      default:
        return Icons.info;
    }
  }

  Color get color {
    switch (type) {
      case 'academic':
        return Colors.blue;
      case 'exam':
        return Colors.red;
      case 'holiday':
        return Colors.green;
      case 'deadline':
        return Colors.orange;
      case 'registration':
        return Colors.purple;
      case 'event':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}