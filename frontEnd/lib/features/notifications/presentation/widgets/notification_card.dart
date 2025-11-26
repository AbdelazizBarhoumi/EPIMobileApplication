// lib/features/notifications/presentation/widgets/notification_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            if (!notification.read) {
              onMarkAsRead?.call();
            }
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIcon(notification.type),
                    color: _getIconColor(notification.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and unread indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.read ? FontWeight.w600 : FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!notification.read)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Message
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Time and type
                      Row(
                        children: [
                          Text(
                            _formatTime(notification.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getIconColor(notification.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notification.type.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getIconColor(notification.type),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action button
                if (!notification.read)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    color: Colors.blue,
                    onPressed: onMarkAsRead,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    return type.iconName == 'payment' ? Icons.payment :
           type.iconName == 'grade' ? Icons.grade :
           type.iconName == 'event' ? Icons.event :
           type.iconName == 'schedule' ? Icons.schedule :
           type.iconName == 'groups' ? Icons.groups :
           Icons.notifications;
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return Colors.red;
      case NotificationType.grade:
        return Colors.green;
      case NotificationType.event:
        return Colors.blue;
      case NotificationType.schedule:
        return Colors.orange;
      case NotificationType.club:
        return Colors.purple;
      case NotificationType.general:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(time);
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }
}