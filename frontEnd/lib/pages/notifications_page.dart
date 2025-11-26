// ============================================================================
// NOTIFICATIONS PAGE - Firebase-powered Notification Center
// ============================================================================
import 'package:flutter/material.dart';
import '../features/notifications/presentation/pages/notifications_page.dart' as firebase_notifications;

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new Firebase-powered notifications page
    return const firebase_notifications.NotificationsPage();
  }
}