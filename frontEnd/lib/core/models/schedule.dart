// ============================================================================
// SCHEDULE MODEL - Represents class schedule
// ============================================================================

class ScheduleSession {
  final int id;
  final String courseCode;
  final String courseName;
  final String? instructor;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;
  final String? sessionType; // lecture, lab, tutorial

  ScheduleSession({
    required this.id,
    required this.courseCode,
    required this.courseName,
    this.instructor,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.sessionType,
  });

  factory ScheduleSession.fromJson(Map<String, dynamic> json) {
    return ScheduleSession(
      id: json['id'] as int,
      courseCode: json['course_code'] as String,
      courseName: json['course_name'] as String,
      instructor: json['instructor'] as String?,
      dayOfWeek: json['day_of_week'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      room: json['room'] as String?,
      sessionType: json['session_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_code': courseCode,
      'course_name': courseName,
      'instructor': instructor,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'session_type': sessionType,
    };
  }

  int get startHour => int.parse(startTime.split(':')[0]);
  int get endHour => int.parse(endTime.split(':')[0]);
  
  Duration get duration {
    final start = DateTime(2000, 1, 1, startHour, int.parse(startTime.split(':')[1]));
    final end = DateTime(2000, 1, 1, endHour, int.parse(endTime.split(':')[1]));
    return end.difference(start);
  }
}

class WeeklySchedule {
  final Map<String, List<ScheduleSession>> schedule;

  WeeklySchedule({required this.schedule});

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    final Map<String, List<ScheduleSession>> schedule = {};
    
    // Backend returns: schedule[day][time_slot] = { course: {...} }
    // We need to flatten to: schedule[day] = [session1, session2, ...]
    json.forEach((day, timeSlotsMap) {
      final List<ScheduleSession> sessions = [];
      
      if (timeSlotsMap is Map) {
        timeSlotsMap.forEach((timeSlot, slotData) {
          // Each slot has: { time_slot, start_time, end_time, course: {...} }
          if (slotData is Map && slotData['course'] != null) {
            final courseData = slotData['course'] as Map<String, dynamic>;
            sessions.add(ScheduleSession(
              id: courseData['id'] as int,
              courseCode: courseData['code'] as String,
              courseName: courseData['name'] as String,
              instructor: courseData['instructor'] as String?,
              dayOfWeek: day,
              startTime: slotData['start_time'] as String,
              endTime: slotData['end_time'] as String,
              room: courseData['room'] as String?,
              sessionType: courseData['session_type'] as String? ?? 'lecture',
            ));
          }
        });
      }
      
      schedule[day] = sessions;
    });
    
    return WeeklySchedule(schedule: schedule);
  }

  List<ScheduleSession> getSessionsForDay(String day) {
    return schedule[day] ?? [];
  }
}
