// lib/features/notifications/presentation/widgets/notification_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/notification_model.dart';

/// Enhanced Notification Card with modern glass-morphism design
/// Features: Priority indicators, swipe actions, smooth animations
class NotificationCard extends StatefulWidget {
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
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    final isUnread = !notification.read;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          _controller.forward();
        },
        onTapUp: (_) {
          _controller.reverse();
        },
        onTapCancel: () {
          _controller.reverse();
        },
        child: Dismissible(
          key: Key(notification.id),
          direction: DismissDirection.endToStart,
          background: _buildDismissBackground(),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              return await _showDeleteConfirmation(context);
            }
            return false;
          },
          onDismissed: (direction) {
            widget.onDelete?.call();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: notification.isCritical
                  ? Border.all(
                      color: notification.priority.color,
                      width: 2,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isUnread
                      ? notification.priority.color.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isUnread ? 16 : 10,
                  offset: const Offset(0, 4),
                  spreadRadius: isUnread ? 2 : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  if (!notification.read) {
                    widget.onMarkAsRead?.call();
                  }
                  widget.onTap?.call();
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Section
                      _buildIconSection(notification),
                      const SizedBox(width: 14),

                      // Content Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            _buildHeader(notification, isUnread),

                            // Priority Badge (for urgent)
                            if (notification.isUrgent) ...[
                              const SizedBox(height: 8),
                              _buildPriorityBadge(notification),
                            ],

                            const SizedBox(height: 10),

                            // Message
                            _buildMessage(notification),

                            // Sender Info
                            if (notification.senderName != null) ...[
                              const SizedBox(height: 8),
                              _buildSenderInfo(notification),
                            ],

                            const SizedBox(height: 12),

                            // Footer
                            _buildFooter(notification),
                          ],
                        ),
                      ),

                      // Mark as read button
                      if (isUnread && !notification.isExpired)
                        _buildReadButton(notification),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSection(NotificationModel notification) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getTypeColor(notification.type).withOpacity(0.15),
                _getTypeColor(notification.type).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type),
            size: 26,
          ),
        ),
        if (notification.isCritical)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.priority_high_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        if (notification.isPinned)
          Positioned(
            top: -4,
            left: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.push_pin_rounded,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(NotificationModel notification, bool isUnread) {
    return Row(
      children: [
        Expanded(
          child: Text(
            notification.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
              color: notification.isExpired
                  ? Colors.grey[400]
                  : const Color(0xFF1A1A2E),
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isUnread) ...[
          const SizedBox(width: 8),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  notification.priority.color,
                  notification.priority.color.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: notification.priority.color.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriorityBadge(NotificationModel notification) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            notification.priority.color.withOpacity(0.15),
            notification.priority.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notification.priority.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            notification.isCritical
                ? Icons.warning_amber_rounded
                : Icons.priority_high_rounded,
            size: 14,
            color: notification.priority.color,
          ),
          const SizedBox(width: 6),
          Text(
            notification.priority.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: notification.priority.color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(NotificationModel notification) {
    return Text(
      notification.message,
      style: TextStyle(
        fontSize: 13,
        color: notification.isExpired ? Colors.grey[400] : Colors.grey[600],
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSenderInfo(NotificationModel notification) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.person_outline_rounded, size: 12, color: Colors.grey[500]),
        ),
        const SizedBox(width: 6),
        Text(
          notification.senderName!,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(NotificationModel notification) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Time chip
        _buildChip(
          label: _formatTime(notification.timestamp),
          icon: Icons.access_time_rounded,
          color: Colors.grey[500]!,
        ),
        // Type chip
        _buildChip(
          label: notification.type.displayName,
          color: _getTypeColor(notification.type),
        ),
        // Expiry chip
        if (notification.expiryDate != null && !notification.isExpired)
          _buildChip(
            label: 'Exp: ${_formatShortDate(notification.expiryDate!)}',
            icon: Icons.timer_outlined,
            color: Colors.orange,
          ),
        // Expired indicator
        if (notification.isExpired)
          _buildChip(
            label: 'EXPIRED',
            icon: Icons.cancel_outlined,
            color: Colors.red,
            filled: true,
          ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    IconData? icon,
    required Color color,
    bool filled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: filled ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: filled ? Colors.white : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadButton(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: notification.priority.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          Icons.check_circle_outline_rounded,
          color: notification.priority.color,
          size: 22,
        ),
        onPressed: widget.onMarkAsRead,
        tooltip: 'Mark as read',
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.delete_rounded, color: Colors.white),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Notification'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this notification? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Helper methods
  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.exam:
        return Icons.school_rounded;
      case NotificationType.payment:
        return Icons.payment_rounded;
      case NotificationType.grade:
        return Icons.grade_rounded;
      case NotificationType.event:
        return Icons.event_rounded;
      case NotificationType.schedule:
        return Icons.schedule_rounded;
      case NotificationType.announcement:
        return Icons.campaign_rounded;
      case NotificationType.club:
        return Icons.groups_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.exam:
        return const Color(0xFFE53935);
      case NotificationType.payment:
        return const Color(0xFFD32F2F);
      case NotificationType.grade:
        return const Color(0xFF43A047);
      case NotificationType.event:
        return const Color(0xFF1E88E5);
      case NotificationType.schedule:
        return const Color(0xFFFB8C00);
      case NotificationType.announcement:
        return const Color(0xFF5E35B1);
      case NotificationType.club:
        return const Color(0xFF8E24AA);
      case NotificationType.general:
        return const Color(0xFF757575);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return DateFormat('MMM d').format(time);
  }

  String _formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }
}
