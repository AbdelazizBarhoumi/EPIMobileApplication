// lib/core/services/firebase/firebase_messaging_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseMessagingService()
      : _messaging = FirebaseMessaging.instance,
        _localNotifications = FlutterLocalNotificationsPlugin(),
        _auth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token and store it
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    
    if (token != null) {
      await _storeFCMToken(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_storeFCMToken);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Store FCM token in Firestore for the current user
  Future<void> _storeFCMToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ Cannot store FCM token: User not authenticated');
        return;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      }, SetOptions(merge: true));

      debugPrint('✅ FCM token stored successfully for user: ${user.uid}');
    } catch (e) {
      debugPrint('❌ Error storing FCM token: $e');
    }
  }

  /// Remove FCM token when user logs out
  Future<void> removeFCMToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': FieldValue.delete(),
      });

      debugPrint('✅ FCM token removed for user: ${user.uid}');
    } catch (e) {
      debugPrint('❌ Error removing FCM token: $e');
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Permission granted: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.notification?.title}');

    // Show local notification
    _showLocalNotification(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.notification?.title}');

    // Navigate to relevant screen based on message data
    _navigateToScreen(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new notification',
      details,
      payload: message.data.toString(),
    );
  }

  /// Show test notification for debugging
  Future<void> showTestNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notification channel for debugging',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
    // Navigate to relevant screen
  }

  void _navigateToScreen(RemoteMessage message) {
    final data = message.data;

    // Navigate based on notification type
    switch (data['type']) {
      case 'chat':
        // Navigate to chat screen
        debugPrint('Navigate to chat: ${data['conversationId']}');
        break;
      case 'notification':
        // Navigate to notifications screen
        debugPrint('Navigate to notifications');
        break;
      default:
        debugPrint('Unknown notification type: ${data['type']}');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Handle background message (e.g., update badge count, etc.)
}