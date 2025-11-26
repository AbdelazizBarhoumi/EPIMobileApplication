// lib/features/notifications/data/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  payment,
  grade,
  event,
  schedule,
  club,
  general;

  String get displayName {
    switch (this) {
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.grade:
        return 'Grade';
      case NotificationType.event:
        return 'Event';
      case NotificationType.schedule:
        return 'Schedule';
      case NotificationType.club:
        return 'Club';
      case NotificationType.general:
        return 'General';
    }
  }

  String get iconName {
    switch (this) {
      case NotificationType.payment:
        return 'payment';
      case NotificationType.grade:
        return 'grade';
      case NotificationType.event:
        return 'event';
      case NotificationType.schedule:
        return 'schedule';
      case NotificationType.club:
        return 'groups';
      case NotificationType.general:
        return 'notifications';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool read;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.read = false,
    this.actionUrl,
  });

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
      read: data['read'] ?? false,
      actionUrl: data['actionUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
      'read': read,
      'actionUrl': actionUrl,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? read,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      read: read ?? this.read,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, read: $read)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}