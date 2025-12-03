// lib/core/services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage.dart';

/// Service for admin/teacher to send notifications via backend API
/// 
/// Architecture:
/// - Frontend calls this service (admin panel only)
/// - Backend securely calls OneSignal API + writes to Firestore
/// - API keys never exposed to frontend
class NotificationService {
  static String get _apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8001';

  /// Send notification to students
  /// 
  /// [targetType]: 'individual', 'class', or 'all'
  /// [targetUsers]: List of user IDs (for individual targeting)
  /// [targetClasses]: List of class/major names (for class targeting)
  Future<NotificationResult> send({
    required String title,
    required String message,
    required String type,
    required String targetType,
    required String senderId,
    required String senderName,
    String? priority,
    List<String>? targetUsers,
    List<String>? targetClasses,
    Map<String, dynamic>? metadata,
  }) async {
    final token = await Storage.readToken();
    if (token == null) {
      return NotificationResult(success: false, error: 'Not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/notifications/send'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'message': message,
          'type': type,
          'target_type': targetType,
          'sender_id': senderId,
          'sender_name': senderName,
          if (priority != null) 'priority': priority,
          if (targetUsers != null) 'target_users': targetUsers,
          if (targetClasses != null) 'target_classes': targetClasses,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      final result = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return NotificationResult(
          success: true,
          notificationId: result['notification_id'],
          recipients: result['recipients'] ?? 0,
        );
      }
      
      return NotificationResult(
        success: false,
        error: result['message'] ?? 'Failed to send notification',
      );
    } catch (e) {
      return NotificationResult(success: false, error: e.toString());
    }
  }

  /// Send notification to specific users by their IDs (for chat notifications)
  /// 
  /// This is a convenience method for sending notifications to specific users,
  /// typically used for chat message notifications.
  Future<bool> sendNotificationByUserIds({
    required List<String> userIds,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    if (userIds.isEmpty) return false;

    final result = await send(
      title: title,
      message: message,
      type: 'chat',
      targetType: 'individual',
      senderId: data?['senderId'] ?? 'system',
      senderName: data?['senderName'] ?? 'Chat',
      targetUsers: userIds,
      metadata: data,
    );

    return result.success;
  }
}

/// Result of a notification send operation
class NotificationResult {
  final bool success;
  final String? notificationId;
  final int? recipients;
  final String? error;

  NotificationResult({
    required this.success,
    this.notificationId,
    this.recipients,
    this.error,
  });
}
