// lib/features/notifications/presentation/controllers/notification_controller.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase/firebase_notification_service.dart';
import '../../data/models/notification_model.dart';

enum NotificationState { loading, loaded, error }

class NotificationController extends ChangeNotifier {
  final FirebaseNotificationService _notificationService;
  final String _userId;

  NotificationController(this._userId, FirebaseFirestore firestore)
      : _notificationService = FirebaseNotificationService(firestore);

  NotificationState _state = NotificationState.loading;
  NotificationState get state => _state;

  String? _error;
  String? get error => _error;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.read).length;

  Stream<List<NotificationModel>>? _notificationStream;

  void initialize() {
    debugPrint('\n🎯 [NOTIFICATION CONTROLLER] Initializing...');
    debugPrint('👤 [NOTIFICATION CONTROLLER] User ID: $_userId');
    _loadNotifications();
  }

  void _loadNotifications() {
    debugPrint('\n📡 [NOTIFICATION CONTROLLER] Loading notifications...');
    debugPrint('👤 [NOTIFICATION CONTROLLER] User ID: $_userId');
    
    _state = NotificationState.loading;
    notifyListeners();

    try {
      debugPrint('🔄 [NOTIFICATION CONTROLLER] Creating notification stream...');
      _notificationStream = _notificationService.getNotifications(_userId);

      // Listen to real-time updates
      _notificationStream!.listen(
        (notifications) {
          debugPrint('\n📬 [NOTIFICATION CONTROLLER] Stream update received');
          debugPrint('📊 [NOTIFICATION CONTROLLER] Notification count: ${notifications.length}');
          
          if (notifications.isEmpty) {
            debugPrint('⚠️ [NOTIFICATION CONTROLLER] No notifications in stream');
          } else {
            debugPrint('✅ [NOTIFICATION CONTROLLER] Notifications loaded:');
            for (var i = 0; i < notifications.length; i++) {
              final n = notifications[i];
              debugPrint('   ${i + 1}. ${n.title} (${n.type.name}, ${n.read ? "read" : "unread"})');
            }
          }
          
          _notifications = notifications;
          _state = NotificationState.loaded;
          debugPrint('✅ [NOTIFICATION CONTROLLER] State changed to: loaded');
          notifyListeners();
        },
        onError: (error) {
          debugPrint('\n❌ [NOTIFICATION CONTROLLER] Stream error occurred');
          debugPrint('❌ [NOTIFICATION CONTROLLER] Error: $error');
          debugPrint('❌ [NOTIFICATION CONTROLLER] Error type: ${error.runtimeType}');
          
          _error = error.toString();
          _state = NotificationState.error;
          notifyListeners();
        },
      );
      
      debugPrint('✅ [NOTIFICATION CONTROLLER] Stream listener attached');
    } catch (e) {
      debugPrint('\n❌ [NOTIFICATION CONTROLLER] Exception during setup');
      debugPrint('❌ [NOTIFICATION CONTROLLER] Exception: $e');
      debugPrint('❌ [NOTIFICATION CONTROLLER] Exception type: ${e.runtimeType}');
      
      _error = e.toString();
      _state = NotificationState.error;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(_userId, notificationId);
      // The stream will automatically update the UI
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead(_userId);
      // The stream will automatically update the UI
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(_userId, notificationId);
      // The stream will automatically update the UI
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }

  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((notification) => !notification.read).toList();
  }

  void refresh() {
    _loadNotifications();
  }

  @override
  void dispose() {
    // Cancel any ongoing subscriptions if needed
    super.dispose();
  }
}