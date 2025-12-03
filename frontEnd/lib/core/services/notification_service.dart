// lib/core/services/notification_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage.dart';

/// Service for sending push notifications via backend API
/// 
/// This service communicates with the Laravel backend which securely
/// handles OneSignal REST API calls. Never expose REST API keys in frontend!
class NotificationService {
  static String get _apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8001';

  /// Send a notification to specific users by their player IDs
  Future<bool> sendNotificationByPlayerIds({
    required List<String> playerIds,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final token = await Storage.readToken();
      if (token == null) {
        debugPrint('❌ No auth token found');
        return false;
      }

      final url = Uri.parse('$_apiBaseUrl/api/notifications/send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'player_ids': playerIds,
          'title': title,
          'message': message,
          if (data != null) 'data': data,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        debugPrint('✅ Notification sent: ${result['recipients']} recipients');
        return true;
      } else {
        debugPrint('❌ Failed to send notification: ${response.statusCode}');
        debugPrint('   Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
      return false;
    }
  }

  /// Send a notification to users by their Firebase user IDs
  Future<bool> sendNotificationByUserIds({
    required List<String> userIds,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final token = await Storage.readToken();
      if (token == null) {
        debugPrint('❌ No auth token found');
        return false;
      }

      final url = Uri.parse('$_apiBaseUrl/api/notifications/send-by-user-id');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_ids': userIds,
          'title': title,
          'message': message,
          if (data != null) 'data': data,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        debugPrint('✅ Notification sent: ${result['recipients']} recipients');
        return true;
      } else {
        debugPrint('❌ Failed to send notification: ${response.statusCode}');
        debugPrint('   Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
      return false;
    }
  }
}
