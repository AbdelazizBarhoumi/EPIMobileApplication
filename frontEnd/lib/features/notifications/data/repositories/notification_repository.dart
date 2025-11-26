// lib/features/notifications/data/repositories/notification_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String userId, String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String userId, String notificationId);
  Future<void> addNotification(String userId, NotificationModel notification);
}

class FirebaseNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _firestore;

  FirebaseNotificationRepository(this._firestore);

  @override
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .doc(notificationId)
        .update({'read': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .where('read', isEqualTo: false)
        .get();

    for (final doc in notifications.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .doc(notificationId)
        .delete();
  }

  @override
  Future<void> addNotification(String userId, NotificationModel notification) async {
    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .doc(notification.id)
        .set(notification.toFirestore());
  }
}