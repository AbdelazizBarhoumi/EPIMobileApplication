// lib/core/services/onesignal_service.dart
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OneSignalService {
  // Load OneSignal App ID from environment variables
  static String get _appId => dotenv.env['ONESIGNAL_APP_ID']!;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentStudentId;

  Future<void> initialize() async {
    debugPrint('🔔 [ONESIGNAL] Initializing OneSignal SDK...');
    
    // Initialize OneSignal
    OneSignal.initialize(_appId);
    debugPrint('🔔 [ONESIGNAL] App ID: $_appId');

    // Request permission
    final permission = await OneSignal.Notifications.requestPermission(true);
    debugPrint('🔔 [ONESIGNAL] Permission granted: $permission');

    // Set up notification handlers
    OneSignal.Notifications.addForegroundWillDisplayListener(_handleForegroundNotification);
    OneSignal.Notifications.addClickListener(_handleNotificationOpened);

    // Check if notifications are enabled
    final hasPermission = await OneSignal.Notifications.permission;
    debugPrint('🔔 [ONESIGNAL] Current notification permission: $hasPermission');
    
    // Get player ID for debugging
    final playerId = await OneSignal.User.getOnesignalId();
    debugPrint('🔔 [ONESIGNAL] OneSignal Player ID: $playerId');

    debugPrint('✅ [ONESIGNAL] Initialization complete - waiting for student login to set external user ID');
  }

  /// Set external user ID in OneSignal using MySQL student.id
  /// Refactor: Use MySQL student.id as external user ID for simplified architecture
  /// This ensures consistency between admin notifications (sent to student.id) and push delivery
  Future<void> setExternalUserId(int studentId) async {
    final studentIdStr = studentId.toString();
    
    if (_currentStudentId == studentIdStr) {
      debugPrint('🔔 OneSignal: Already logged in with student ID: $studentIdStr');
      return;
    }

    try {
      OneSignal.login(studentIdStr);
      _currentStudentId = studentIdStr;
      debugPrint('✅ OneSignal: Logged in with external user ID (student.id): $studentIdStr');

      // Store OneSignal player ID in Firestore for reference
      final playerId = await OneSignal.User.getOnesignalId();
      if (playerId != null) {
        await _storePlayerId(playerId, studentIdStr);
      }
    } catch (e) {
      debugPrint('❌ OneSignal: Error setting external user ID: $e');
    }
  }

  /// Logout from OneSignal (call when user logs out)
  Future<void> logout() async {
    try {
      OneSignal.logout();
      _currentStudentId = null;
      debugPrint('✅ OneSignal: Logged out');
    } catch (e) {
      debugPrint('❌ OneSignal: Error logging out: $e');
    }
  }

  void _handleForegroundNotification(OSNotificationWillDisplayEvent event) {
    debugPrint('🔔 [ONESIGNAL FOREGROUND] ================================');
    debugPrint('🔔 [ONESIGNAL FOREGROUND] Title: ${event.notification.title}');
    debugPrint('🔔 [ONESIGNAL FOREGROUND] Body: ${event.notification.body}');
    debugPrint('🔔 [ONESIGNAL FOREGROUND] Data: ${event.notification.additionalData}');
    debugPrint('🔔 [ONESIGNAL FOREGROUND] Notification ID: ${event.notification.notificationId}');
    
    // IMPORTANT: Call display() to show the notification in foreground
    // By default, OneSignal suppresses foreground notifications
    event.notification.display();
    
    debugPrint('🔔 [ONESIGNAL FOREGROUND] Notification displayed!');
    debugPrint('🔔 [ONESIGNAL FOREGROUND] ================================');
  }

  void _handleNotificationOpened(OSNotificationClickEvent event) {
    debugPrint('Notification opened: ${event.notification.title}');
    // Navigate to relevant screen based on notification data
    final data = event.notification.additionalData;
    if (data != null) {
      switch (data['type']) {
        case 'chat':
          // Navigate to chat
          debugPrint('Navigate to chat: ${data['conversationId']}');
          break;
        default:
          debugPrint('Unknown notification type');
      }
    }
  }

  /// Note: Notification sending is now handled by the backend API
  /// for security reasons (REST API key should never be in frontend code).
  /// Use the backend endpoint: POST /api/notifications/send

  /// Store OneSignal player ID in Firestore for reference
  Future<void> _storePlayerId(String playerId, String studentId) async {
    try {
      await _firestore.collection('onesignal_players').doc(studentId).set({
        'oneSignalPlayerId': playerId,
        'studentId': studentId,
        'lastUpdate': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      }, SetOptions(merge: true));

      debugPrint('✅ OneSignal player ID stored for student: $studentId');
    } catch (e) {
      debugPrint('❌ Error storing OneSignal player ID: $e');
    }
  }

  /// Get user's OneSignal player ID from Firestore
  Future<String?> getUserPlayerId(String studentId) async {
    try {
      final doc = await _firestore.collection('onesignal_players').doc(studentId).get();
      return doc.data()?['oneSignalPlayerId'] as String?;
    } catch (e) {
      debugPrint('❌ Error getting player ID for student $studentId: $e');
      return null;
    }
  }
}