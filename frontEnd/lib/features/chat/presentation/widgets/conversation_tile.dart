// lib/features/chat/presentation/widgets/conversation_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback? onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: hasUnread ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: hasUnread
            ? BorderSide(color: Colors.red[300]!, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: conversation.professorInfo.avatar.isNotEmpty
                        ? AssetImage(conversation.professorInfo.avatar)
                        : null,
                    backgroundColor: Colors.red[900],
                    child: conversation.professorInfo.avatar.isEmpty
                        ? Text(
                            conversation.professorInfo.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        // Show realistic presence based on recent activity
                        color: _getPresenceColor(),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Message Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            conversation.professorInfo.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                              color: Colors.red[900],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          conversation.lastMessage != null
                              ? _formatTime(conversation.lastMessage!.timestamp)
                              : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread ? Colors.red[700] : Colors.grey[600],
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            conversation.professorInfo.course,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage?.text ?? 'No messages yet',
                            style: TextStyle(
                              fontSize: 14,
                              color: hasUnread ? Colors.black87 : Colors.grey[600],
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[700],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          conversation.professorInfo.building,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get presence color based on last message time and business hours
  Color _getPresenceColor() {
    if (conversation.lastMessage == null) {
      return Colors.grey; // No recent activity
    }

    final now = DateTime.now();
    final lastMessageTime = conversation.lastMessage!.timestamp;
    final timeDifference = now.difference(lastMessageTime);

    // If last message was within 5 minutes, show as online
    if (timeDifference.inMinutes < 5) {
      return Colors.green;
    }

    // If during business hours and last message was within 2 hours, show as away
    if (_isBusinessHours() && timeDifference.inHours < 2) {
      return Colors.orange;
    }

    // Otherwise show as offline
    return Colors.grey;
  }

  bool _isBusinessHours() {
    final now = DateTime.now();
    final hour = now.hour;
    final dayOfWeek = now.weekday;
    
    // Monday = 1, Sunday = 7
    // Business hours: Monday-Friday, 8 AM to 6 PM
    return dayOfWeek >= 1 && dayOfWeek <= 5 && hour >= 8 && hour <= 18;
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