// lib/core/services/firebase/firebase_notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/notifications/data/models/notification_model.dart';
import '../../../features/notifications/data/repositories/notification_repository.dart';

class FirebaseNotificationService {
  final NotificationRepository _repository;

  FirebaseNotificationService(FirebaseFirestore firestore)
      : _repository = FirebaseNotificationRepository(firestore);

  /// Get real-time notifications stream for a user
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _repository.getNotifications(userId);
  }

  /// Mark a specific notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    await _repository.markAsRead(userId, notificationId);
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    await _repository.markAllAsRead(userId);
  }

  /// Delete a specific notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _repository.deleteNotification(userId, notificationId);
  }

  /// Add a new notification (typically called from backend/admin)
  Future<void> addNotification(String userId, NotificationModel notification) async {
    await _repository.addNotification(userId, notification);
  }

  /// Get unread notifications count
  Stream<int> getUnreadCount(String userId) {
    return getNotifications(userId).map((notifications) =>
        notifications.where((notification) => !notification.read).length);
  }

  /// Get notifications by type
  Stream<List<NotificationModel>> getNotificationsByType(String userId, NotificationType type) {
    return getNotifications(userId).map((notifications) =>
        notifications.where((notification) => notification.type == type).toList());
  }
}