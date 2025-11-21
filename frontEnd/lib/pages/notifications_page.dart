// ============================================================================
// NOTIFICATIONS PAGE - Notification Center
// ============================================================================
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/custom_app_bar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: () {
              // TODO: Mark all as read
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Today',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildNotificationCard(
            'Payment Reminder',
            'Your tuition fee of TND 2,500 is due on Dec 31, 2024',
            '2 hours ago',
            Icons.payment,
            Colors.red,
            true,
          ),
          _buildNotificationCard(
            'New Grade Posted',
            'Your grade for Data Structures has been posted',
            '5 hours ago',
            Icons.grade,
            Colors.green,
            true,
          ),
          const SizedBox(height: 20),
          Text(
            'Yesterday',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildNotificationCard(
            'Event Registration',
            'You have been registered for Tech Innovation Workshop',
            'Yesterday, 3:30 PM',
            Icons.event,
            Colors.blue,
            false,
          ),
          _buildNotificationCard(
            'Schedule Change',
            'Software Engineering class moved to Room A-205',
            'Yesterday, 10:15 AM',
            Icons.schedule,
            Colors.orange,
            false,
          ),
          const SizedBox(height: 20),
          Text(
            'Earlier',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildNotificationCard(
            'Club Invitation',
            'You have been invited to join the Tech Club',
            'Dec 10, 2024',
            Icons.groups,
            Colors.purple,
            false,
          ),
          _buildNotificationCard(
            'Course Registration',
            'Spring 2025 course registration is now open',
            'Dec 8, 2024',
            Icons.app_registration,
            Colors.teal,
            false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationCard(
    String title,
    String message,
    String time,
    IconData icon,
    Color color,
    bool isUnread,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

