// lib/features/notifications/data/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum NotificationType {
  exam,        // High priority - exam announcements
  payment,     // High priority - payment deadlines
  grade,       // Medium priority - grade updates
  event,       // Medium priority - campus events
  schedule,    // Medium priority - schedule changes
  announcement,// Variable priority - admin announcements
  club,        // Low priority - club activities
  general;     // Low priority - general info

  String get displayName {
    switch (this) {
      case NotificationType.exam:
        return 'Exam';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.grade:
        return 'Grade';
      case NotificationType.event:
        return 'Event';
      case NotificationType.schedule:
        return 'Schedule';
      case NotificationType.announcement:
        return 'Announcement';
      case NotificationType.club:
        return 'Club';
      case NotificationType.general:
        return 'General';
    }
  }

  String get iconName {
    switch (this) {
      case NotificationType.exam:
        return 'school';
      case NotificationType.payment:
        return 'payment';
      case NotificationType.grade:
        return 'grade';
      case NotificationType.event:
        return 'event';
      case NotificationType.schedule:
        return 'schedule';
      case NotificationType.announcement:
        return 'campaign';
      case NotificationType.club:
        return 'groups';
      case NotificationType.general:
        return 'notifications';
    }
  }

  NotificationPriority get defaultPriority {
    switch (this) {
      case NotificationType.exam:
      case NotificationType.payment:
        return NotificationPriority.critical;
      case NotificationType.grade:
      case NotificationType.event:
      case NotificationType.schedule:
        return NotificationPriority.high;
      case NotificationType.announcement:
        return NotificationPriority.medium;
      case NotificationType.club:
      case NotificationType.general:
        return NotificationPriority.low;
    }
  }
}

enum NotificationPriority {
  critical,  // Urgent - Exams, payment deadlines, emergency
  high,      // Important - Grades, schedule changes
  medium,    // Normal - Events, announcements
  low;       // Info - Clubs, general updates

  String get displayName {
    switch (this) {
      case NotificationPriority.critical:
        return 'URGENT';
      case NotificationPriority.high:
        return 'Important';
      case NotificationPriority.medium:
        return 'Normal';
      case NotificationPriority.low:
        return 'Info';
    }
  }

  Color get color {
    switch (this) {
      case NotificationPriority.critical:
        return Colors.red;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.low:
        return Colors.grey;
    }
  }

  int get sortOrder {
    switch (this) {
      case NotificationPriority.critical:
        return 0;
      case NotificationPriority.high:
        return 1;
      case NotificationPriority.medium:
        return 2;
      case NotificationPriority.low:
        return 3;
    }
  }
}

enum NotificationTarget {
  individual,  // Single user
  classGroup,  // Specific class/group
  major,       // Specific major/program
  allStudents, // All students
  custom;      // Custom user list

  String get displayName {
    switch (this) {
      case NotificationTarget.individual:
        return 'Individual';
      case NotificationTarget.classGroup:
        return 'Class/Group';
      case NotificationTarget.major:
        return 'Major/Program';
      case NotificationTarget.allStudents:
        return 'All Students';
      case NotificationTarget.custom:
        return 'Custom List';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final NotificationPriority priority;
  final bool read;
  final String? actionUrl;
  final DateTime? expiryDate;
  final String? senderId;
  final String? senderName;
  final NotificationTarget? targetType;
  final List<String>? targetIds;
  final Map<String, dynamic>? metadata;
  final bool isPinned;
  final int? reminderCount;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    NotificationPriority? priority,
    this.read = false,
    this.actionUrl,
    this.expiryDate,
    this.senderId,
    this.senderName,
    this.targetType,
    this.targetIds,
    this.metadata,
    this.isPinned = false,
    this.reminderCount = 0,
  }) : priority = priority ?? type.defaultPriority;

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get isCritical => priority == NotificationPriority.critical;
  bool get isUrgent => priority == NotificationPriority.high || priority == NotificationPriority.critical;

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.general,
      ),
      priority: data['priority'] != null
          ? NotificationPriority.values.firstWhere(
              (e) => e.name == data['priority'],
              orElse: () => NotificationPriority.medium,
            )
          : null,
      read: data['read'] ?? false,
      actionUrl: data['actionUrl'],
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      senderId: data['senderId'],
      senderName: data['senderName'],
      targetType: data['targetType'] != null
          ? NotificationTarget.values.firstWhere(
              (e) => e.name == data['targetType'],
              orElse: () => NotificationTarget.individual,
            )
          : null,
      targetIds: data['targetIds'] != null
          ? List<String>.from(data['targetIds'])
          : null,
      metadata: data['metadata'],
      isPinned: data['isPinned'] ?? false,
      reminderCount: data['reminderCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
      'priority': priority.name,
      'read': read,
      'actionUrl': actionUrl,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'senderId': senderId,
      'senderName': senderName,
      'targetType': targetType?.name,
      'targetIds': targetIds,
      'metadata': metadata,
      'isPinned': isPinned,
      'reminderCount': reminderCount,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    NotificationPriority? priority,
    bool? read,
    String? actionUrl,
    DateTime? expiryDate,
    String? senderId,
    String? senderName,
    NotificationTarget? targetType,
    List<String>? targetIds,
    Map<String, dynamic>? metadata,
    bool? isPinned,
    int? reminderCount,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      read: read ?? this.read,
      actionUrl: actionUrl ?? this.actionUrl,
      expiryDate: expiryDate ?? this.expiryDate,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      targetType: targetType ?? this.targetType,
      targetIds: targetIds ?? this.targetIds,
      metadata: metadata ?? this.metadata,
      isPinned: isPinned ?? this.isPinned,
      reminderCount: reminderCount ?? this.reminderCount,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, priority: $priority, read: $read)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}