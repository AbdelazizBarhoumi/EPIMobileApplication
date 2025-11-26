// lib/features/chat/presentation/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.red[700] : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),

                  // File attachment (if any)
                  if (message.fileUrl != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getFileIcon(message.type),
                            size: 16,
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              message.fileName ?? 'Attachment',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Timestamp and Status
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  // Read status (only for sent messages)
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 14,
          color: Colors.grey[600],
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 14,
          color: Colors.grey[600],
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all,
          size: 14,
          color: Colors.blue,
        );
    }
  }

  IconData _getFileIcon(MessageType type) {
    switch (type) {
      case MessageType.image:
        return Icons.image;
      case MessageType.file:
        return Icons.attach_file;
      default:
        return Icons.textsms;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(time)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE HH:mm').format(time);
    } else {
      return DateFormat('MMM dd, HH:mm').format(time);
    }
  }
}