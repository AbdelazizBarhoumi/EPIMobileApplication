// lib/features/notifications/presentation/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_card.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize controller with authenticated user ID
    final firestore = FirebaseFirestore.instance;
    final userId = FirebaseService.instance.auth.currentUserId ?? 'anonymous';
    _controller = NotificationController(userId, firestore);
    _controller.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            Consumer<NotificationController>(
              builder: (context, controller, child) {
                if (controller.unreadCount > 0) {
                  return IconButton(
                    icon: const Icon(Icons.done_all, color: Colors.white),
                    onPressed: controller.markAllAsRead,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Unread'),
              Tab(text: 'Types'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAllNotifications(),
            _buildUnreadNotifications(),
            _buildNotificationsByType(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllNotifications() {
    return Consumer<NotificationController>(
      builder: (context, controller, child) {
        if (controller.state == NotificationState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.state == NotificationState.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Failed to load notifications',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.error ?? 'Unknown error',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return NotificationCard(
                notification: notification,
                onMarkAsRead: () => controller.markAsRead(notification.id),
                onDelete: () => controller.deleteNotification(notification.id),
                onTap: () => _handleNotificationTap(notification),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUnreadNotifications() {
    return Consumer<NotificationController>(
      builder: (context, controller, child) {
        final unreadNotifications = controller.getUnreadNotifications();

        if (unreadNotifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
                const SizedBox(height: 16),
                Text(
                  'All caught up!',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: unreadNotifications.length,
          itemBuilder: (context, index) {
            final notification = unreadNotifications[index];
            return NotificationCard(
              notification: notification,
              onMarkAsRead: () => controller.markAsRead(notification.id),
              onDelete: () => controller.deleteNotification(notification.id),
              onTap: () => _handleNotificationTap(notification),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationsByType() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: NotificationType.values.map((type) {
        return Consumer<NotificationController>(
          builder: (context, controller, child) {
            final typeNotifications = controller.getNotificationsByType(type);
            if (typeNotifications.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    type.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                ...typeNotifications.map((notification) => NotificationCard(
                  notification: notification,
                  onMarkAsRead: () => controller.markAsRead(notification.id),
                  onDelete: () => controller.deleteNotification(notification.id),
                  onTap: () => _handleNotificationTap(notification),
                )),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      }).toList(),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle navigation based on notification type and actionUrl
    switch (notification.type) {
      case NotificationType.payment:
        // Navigate to bills page
        Navigator.pushNamed(context, '/bills');
        break;
      case NotificationType.grade:
        // Navigate to grades page
        Navigator.pushNamed(context, '/grades');
        break;
      case NotificationType.event:
        // Navigate to events page
        Navigator.pushNamed(context, '/events');
        break;
      case NotificationType.schedule:
        // Navigate to schedule page
        Navigator.pushNamed(context, '/schedule');
        break;
      case NotificationType.club:
        // Navigate to clubs page
        Navigator.pushNamed(context, '/clubs');
        break;
      case NotificationType.general:
        // Handle general notifications
        break;
    }

    // If there's a specific action URL, handle it
    if (notification.actionUrl != null) {
      // Handle deep linking or specific navigation
      debugPrint('Navigate to: ${notification.actionUrl}');
    }
  }
}