// lib/features/notifications/data/models/notification_template.dart
import 'notification_model.dart';

class NotificationTemplate {
  final String id;
  final String name;
  final NotificationType type;
  final NotificationPriority priority;
  final String titleTemplate;
  final String messageTemplate;
  final List<String> variables;
  final String? actionUrl;
  final bool requiresExpiry;

  const NotificationTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.priority,
    required this.titleTemplate,
    required this.messageTemplate,
    required this.variables,
    this.actionUrl,
    this.requiresExpiry = false,
  });

  String fillTemplate(String template, Map<String, String> values) {
    String result = template;
    for (final variable in variables) {
      if (values.containsKey(variable)) {
        result = result.replaceAll('{$variable}', values[variable]!);
      }
    }
    return result;
  }

  String getTitle(Map<String, String> values) {
    return fillTemplate(titleTemplate, values);
  }

  String getMessage(Map<String, String> values) {
    return fillTemplate(messageTemplate, values);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationTemplate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Pre-built notification templates for common scenarios
class NotificationTemplates {
  // ============================================================
  // EXAM TEMPLATES (CRITICAL PRIORITY)
  // ============================================================
  
  static const examAnnouncement = NotificationTemplate(
    id: 'exam_announcement',
    name: 'Exam Announcement',
    type: NotificationType.exam,
    priority: NotificationPriority.critical,
    titleTemplate: '📝 {course} Exam Scheduled',
    messageTemplate: 'Your {course} exam is scheduled for {date} at {time}. '
        'Location: {location}. Please arrive 15 minutes early.',
    variables: ['course', 'date', 'time', 'location'],
    actionUrl: '/schedule',
    requiresExpiry: true,
  );

  static const examReminder = NotificationTemplate(
    id: 'exam_reminder',
    name: 'Exam Reminder (24h)',
    type: NotificationType.exam,
    priority: NotificationPriority.critical,
    titleTemplate: '⏰ Exam Tomorrow: {course}',
    messageTemplate: 'Reminder: Your {course} exam is tomorrow at {time}. '
        'Location: {location}. Make sure you have everything ready!',
    variables: ['course', 'time', 'location'],
    actionUrl: '/schedule',
  );

  static const examRescheduled = NotificationTemplate(
    id: 'exam_rescheduled',
    name: 'Exam Rescheduled',
    type: NotificationType.exam,
    priority: NotificationPriority.critical,
    titleTemplate: '🔄 URGENT: {course} Exam Rescheduled',
    messageTemplate: 'IMPORTANT: Your {course} exam has been rescheduled. '
        'New date: {newDate} at {newTime}. Location: {location}. '
        'Previous date was {oldDate}.',
    variables: ['course', 'newDate', 'newTime', 'location', 'oldDate'],
    actionUrl: '/schedule',
  );

  static const examCancelled = NotificationTemplate(
    id: 'exam_cancelled',
    name: 'Exam Cancelled',
    type: NotificationType.exam,
    priority: NotificationPriority.critical,
    titleTemplate: '❌ {course} Exam Cancelled',
    messageTemplate: 'The {course} exam scheduled for {date} has been cancelled. '
        'Reason: {reason}. A new date will be announced soon.',
    variables: ['course', 'date', 'reason'],
    actionUrl: '/schedule',
  );

  // ============================================================
  // PAYMENT TEMPLATES (CRITICAL/HIGH PRIORITY)
  // ============================================================
  
  static const paymentDue = NotificationTemplate(
    id: 'payment_due',
    name: 'Payment Due',
    type: NotificationType.payment,
    priority: NotificationPriority.critical,
    titleTemplate: '💳 Payment Due: {amount}',
    messageTemplate: 'Your {paymentType} payment of {amount} is due by {dueDate}. '
        'Please make payment to avoid late fees.',
    variables: ['paymentType', 'amount', 'dueDate'],
    actionUrl: '/bills',
    requiresExpiry: true,
  );

  static const paymentReminder = NotificationTemplate(
    id: 'payment_reminder',
    name: 'Payment Reminder',
    type: NotificationType.payment,
    priority: NotificationPriority.high,
    titleTemplate: '⚠️ Payment Reminder: {daysLeft} Days Left',
    messageTemplate: 'Reminder: Your {paymentType} payment of {amount} is due in {daysLeft} days. '
        'Due date: {dueDate}. Pay now to avoid late fees.',
    variables: ['paymentType', 'amount', 'daysLeft', 'dueDate'],
    actionUrl: '/bills',
  );

  static const paymentOverdue = NotificationTemplate(
    id: 'payment_overdue',
    name: 'Payment Overdue',
    type: NotificationType.payment,
    priority: NotificationPriority.critical,
    titleTemplate: '🚨 OVERDUE: Payment Required',
    messageTemplate: 'URGENT: Your {paymentType} payment of {amount} is overdue. '
        'Original due date: {dueDate}. Late fee of {lateFee} has been applied. '
        'Total due: {totalAmount}.',
    variables: ['paymentType', 'amount', 'dueDate', 'lateFee', 'totalAmount'],
    actionUrl: '/bills',
  );

  static const paymentReceived = NotificationTemplate(
    id: 'payment_received',
    name: 'Payment Received',
    type: NotificationType.payment,
    priority: NotificationPriority.medium,
    titleTemplate: '✅ Payment Received',
    messageTemplate: 'Thank you! Your {paymentType} payment of {amount} has been received on {date}. '
        'Receipt number: {receiptNumber}.',
    variables: ['paymentType', 'amount', 'date', 'receiptNumber'],
    actionUrl: '/bills',
  );

  // ============================================================
  // GRADE TEMPLATES (HIGH PRIORITY)
  // ============================================================
  
  static const gradePosted = NotificationTemplate(
    id: 'grade_posted',
    name: 'Grade Posted',
    type: NotificationType.grade,
    priority: NotificationPriority.high,
    titleTemplate: '📊 New Grade: {course}',
    messageTemplate: 'Your grade for {course} {assessmentType} has been posted. '
        'Check your grades page to view your result.',
    variables: ['course', 'assessmentType'],
    actionUrl: '/grades',
  );

  static const gradeUpdated = NotificationTemplate(
    id: 'grade_updated',
    name: 'Grade Updated',
    type: NotificationType.grade,
    priority: NotificationPriority.high,
    titleTemplate: '🔄 Grade Updated: {course}',
    messageTemplate: 'Your {course} {assessmentType} grade has been updated. '
        'Previous: {oldGrade}, New: {newGrade}. Reason: {reason}.',
    variables: ['course', 'assessmentType', 'oldGrade', 'newGrade', 'reason'],
    actionUrl: '/grades',
  );

  static const semesterResults = NotificationTemplate(
    id: 'semester_results',
    name: 'Semester Results Available',
    type: NotificationType.grade,
    priority: NotificationPriority.high,
    titleTemplate: '🎓 {semester} Results Available',
    messageTemplate: 'Your {semester} semester results are now available. '
        'GPA: {gpa}. Check your grades page for detailed results.',
    variables: ['semester', 'gpa'],
    actionUrl: '/grades',
  );

  // ============================================================
  // SCHEDULE TEMPLATES (MEDIUM/HIGH PRIORITY)
  // ============================================================
  
  static const classRescheduled = NotificationTemplate(
    id: 'class_rescheduled',
    name: 'Class Rescheduled',
    type: NotificationType.schedule,
    priority: NotificationPriority.high,
    titleTemplate: '📅 {course} Class Rescheduled',
    messageTemplate: 'Your {course} class has been moved. New time: {newTime}. '
        'New location: {newLocation}. Original time was {oldTime}.',
    variables: ['course', 'newTime', 'newLocation', 'oldTime'],
    actionUrl: '/schedule',
  );

  static const classCancelled = NotificationTemplate(
    id: 'class_cancelled',
    name: 'Class Cancelled',
    type: NotificationType.schedule,
    priority: NotificationPriority.high,
    titleTemplate: '❌ {course} Class Cancelled',
    messageTemplate: 'Your {course} class on {date} at {time} has been cancelled. '
        'Reason: {reason}.',
    variables: ['course', 'date', 'time', 'reason'],
    actionUrl: '/schedule',
  );

  static const roomChanged = NotificationTemplate(
    id: 'room_changed',
    name: 'Room Changed',
    type: NotificationType.schedule,
    priority: NotificationPriority.medium,
    titleTemplate: '🚪 Room Change: {course}',
    messageTemplate: '{course} class location changed. New room: {newRoom}. '
        'Date: {date}, Time: {time}.',
    variables: ['course', 'newRoom', 'date', 'time'],
    actionUrl: '/schedule',
  );

  // ============================================================
  // EVENT TEMPLATES (MEDIUM PRIORITY)
  // ============================================================
  
  static const eventAnnouncement = NotificationTemplate(
    id: 'event_announcement',
    name: 'Event Announcement',
    type: NotificationType.event,
    priority: NotificationPriority.medium,
    titleTemplate: '🎉 {eventName}',
    messageTemplate: '{eventName} is happening on {date} at {time}. '
        'Location: {location}. {description}',
    variables: ['eventName', 'date', 'time', 'location', 'description'],
    actionUrl: '/events',
  );

  static const eventReminder = NotificationTemplate(
    id: 'event_reminder',
    name: 'Event Reminder',
    type: NotificationType.event,
    priority: NotificationPriority.medium,
    titleTemplate: '⏰ Reminder: {eventName}',
    messageTemplate: '{eventName} starts in {timeUntil}! '
        'Location: {location}. Don\'t miss it!',
    variables: ['eventName', 'timeUntil', 'location'],
    actionUrl: '/events',
  );

  // ============================================================
  // ANNOUNCEMENT TEMPLATES (VARIABLE PRIORITY)
  // ============================================================
  
  static const generalAnnouncement = NotificationTemplate(
    id: 'general_announcement',
    name: 'General Announcement',
    type: NotificationType.announcement,
    priority: NotificationPriority.medium,
    titleTemplate: '📢 {title}',
    messageTemplate: '{message}',
    variables: ['title', 'message'],
  );

  static const urgentAnnouncement = NotificationTemplate(
    id: 'urgent_announcement',
    name: 'Urgent Announcement',
    type: NotificationType.announcement,
    priority: NotificationPriority.critical,
    titleTemplate: '🚨 URGENT: {title}',
    messageTemplate: 'URGENT: {message}',
    variables: ['title', 'message'],
  );

  static const maintenanceNotice = NotificationTemplate(
    id: 'maintenance_notice',
    name: 'Maintenance Notice',
    type: NotificationType.announcement,
    priority: NotificationPriority.medium,
    titleTemplate: '🔧 Maintenance: {facility}',
    messageTemplate: '{facility} will be under maintenance from {startTime} to {endTime} on {date}. '
        '{details}',
    variables: ['facility', 'startTime', 'endTime', 'date', 'details'],
  );

  // ============================================================
  // CLUB TEMPLATES (LOW PRIORITY)
  // ============================================================
  
  static const clubMeeting = NotificationTemplate(
    id: 'club_meeting',
    name: 'Club Meeting',
    type: NotificationType.club,
    priority: NotificationPriority.low,
    titleTemplate: '👥 {clubName} Meeting',
    messageTemplate: '{clubName} meeting on {date} at {time}. '
        'Location: {location}. Agenda: {agenda}.',
    variables: ['clubName', 'date', 'time', 'location', 'agenda'],
    actionUrl: '/clubs',
  );

  static const clubEvent = NotificationTemplate(
    id: 'club_event',
    name: 'Club Event',
    type: NotificationType.club,
    priority: NotificationPriority.low,
    titleTemplate: '🎯 {clubName}: {eventName}',
    messageTemplate: '{clubName} is organizing {eventName} on {date} at {time}. '
        '{description}',
    variables: ['clubName', 'eventName', 'date', 'time', 'description'],
    actionUrl: '/clubs',
  );

  // ============================================================
  // TEMPLATE LIST
  // ============================================================
  
  static final List<NotificationTemplate> allTemplates = [
    // Exams
    examAnnouncement,
    examReminder,
    examRescheduled,
    examCancelled,
    // Payments
    paymentDue,
    paymentReminder,
    paymentOverdue,
    paymentReceived,
    // Grades
    gradePosted,
    gradeUpdated,
    semesterResults,
    // Schedule
    classRescheduled,
    classCancelled,
    roomChanged,
    // Events
    eventAnnouncement,
    eventReminder,
    // Announcements
    generalAnnouncement,
    urgentAnnouncement,
    maintenanceNotice,
    // Clubs
    clubMeeting,
    clubEvent,
  ];

  static NotificationTemplate? getTemplate(String id) {
    try {
      return allTemplates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<NotificationTemplate> getTemplatesByType(NotificationType type) {
    return allTemplates.where((t) => t.type == type).toList();
  }

  static List<NotificationTemplate> getTemplatesByPriority(NotificationPriority priority) {
    return allTemplates.where((t) => t.priority == priority).toList();
  }
}
