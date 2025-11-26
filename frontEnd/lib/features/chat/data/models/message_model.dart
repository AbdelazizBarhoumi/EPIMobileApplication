// lib/features/chat/data/models/message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  file;

  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.file:
        return 'File';
    }
  }
}

enum MessageStatus {
  sending,   // Message is being sent
  sent,      // Message sent to server
  delivered, // Message delivered to recipient
  read;      // Message read by recipient

  String get displayName {
    switch (this) {
      case MessageStatus.sending:
        return 'Sending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
    }
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool read;
  final MessageType type;
  final MessageStatus status;
  final String? fileUrl;
  final String? fileName;
  final Map<String, List<String>> reactions; // emoji -> list of userIds

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.read = false,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.fileUrl,
    this.fileName,
    this.reactions = const {},
  }) {
    if (id.isEmpty) throw ArgumentError('Message ID cannot be empty');
    if (senderId.isEmpty) throw ArgumentError('Sender ID cannot be empty');
    if (content.isEmpty && type == MessageType.text) {
      throw ArgumentError('Text message content cannot be empty');
    }
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse reactions
    Map<String, List<String>> reactions = {};
    if (data['reactions'] != null) {
      final reactionsData = data['reactions'] as Map<String, dynamic>;
      reactionsData.forEach((emoji, users) {
        reactions[emoji] = List<String>.from(users as List);
      });
    }
    
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      reactions: reactions,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
      'type': type.name,
      'status': status.name,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'reactions': reactions,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? read,
    MessageType? type,
    MessageStatus? status,
    String? fileUrl,
    String? fileName,
    Map<String, List<String>>? reactions,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      type: type ?? this.type,
      status: status ?? this.status,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      reactions: reactions ?? this.reactions,
    );
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, senderId: $senderId, type: $type, read: $read)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}