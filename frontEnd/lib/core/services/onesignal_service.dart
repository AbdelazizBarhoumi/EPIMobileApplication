// lib/core/services/onesignal_service.dart
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OneSignalService {
  static String get _appId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  static String get _restApiKey => dotenv.env['ONESIGNAL_REST_API_KEY'] ?? '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // Initialize OneSignal
    OneSignal.initialize(_appId);

    // Request permission
    OneSignal.Notifications.requestPermission(true);

    // Set up notification handlers
    OneSignal.Notifications.addForegroundWillDisplayListener(_handleForegroundNotification);
    OneSignal.Notifications.addClickListener(_handleNotificationOpened);

    // Get and store OneSignal player ID
    final playerId = await OneSignal.User.getOnesignalId();
    if (playerId != null) {
      debugPrint('OneSignal Player ID: $playerId');
      await _storePlayerId(playerId);
    }
  }

  void _handleForegroundNotification(OSNotificationWillDisplayEvent event) {
    debugPrint('Received foreground notification: ${event.notification.title}');
    // Show the notification
    event.notification.display();
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

  /// Send notification to a specific user via OneSignal REST API
  Future<void> sendNotification({
    required String playerId,
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final url = Uri.parse('https://onesignal.com/api/v1/notifications');

      final body = {
        'app_id': _appId,
        'include_player_ids': [playerId],
        'headings': {'en': title},
        'contents': {'en': message},
        'data': additionalData ?? {},
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ OneSignal notification sent successfully');
      } else {
        debugPrint('❌ Failed to send OneSignal notification: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error sending OneSignal notification: $e');
    }
  }

  /// Store OneSignal player ID in Firestore for the current user
  Future<void> _storePlayerId(String playerId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ Cannot store OneSignal player ID: User not authenticated');
        return;
      }

      // Set external user ID in OneSignal
      await OneSignal.login(user.uid);
      debugPrint('✅ OneSignal external user ID set: ${user.uid}');

      await _firestore.collection('users').doc(user.uid).set({
        'oneSignalPlayerId': playerId,
        'lastPlayerIdUpdate': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      }, SetOptions(merge: true));

      debugPrint('✅ OneSignal player ID stored successfully for user: ${user.uid}');
    } catch (e) {
      debugPrint('❌ Error storing OneSignal player ID: $e');
    }
  }

  /// Get user's OneSignal player ID from Firestore
  Future<String?> getUserPlayerId(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['oneSignalPlayerId'] as String?;
    } catch (e) {
      debugPrint('❌ Error getting player ID for user $userId: $e');
      return null;
    }
  }
}