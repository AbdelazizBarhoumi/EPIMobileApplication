// lib/features/chat/data/models/conversation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessorInfo {
  final String id;
  final String name;
  final String course;
  final String avatar;
  final String building;

  ProfessorInfo({
    required this.id,
    required this.name,
    required this.course,
    required this.avatar,
    required this.building,
  }) {
    if (id.isEmpty) throw ArgumentError('Professor ID cannot be empty');
    if (name.trim().isEmpty) throw ArgumentError('Professor name cannot be empty');
  }

  factory ProfessorInfo.fromMap(Map<String, dynamic> map) {
    return ProfessorInfo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      course: map['course'] ?? '',
      avatar: map['avatar'] ?? '',
      building: map['building'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'course': course,
      'avatar': avatar,
      'building': building,
    };
  }
}

class LastMessage {
  final String text;
  final DateTime timestamp;
  final String senderId;

  LastMessage({
    required this.text,
    required this.timestamp,
    required this.senderId,
  });

  factory LastMessage.fromMap(Map<String, dynamic> map) {
    return LastMessage(
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      senderId: map['senderId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'senderId': senderId,
    };
  }
}

class ConversationModel {
  final String id;
  final List<String> participantIds;
  final ProfessorInfo professorInfo;
  final LastMessage? lastMessage;
  final int unreadCount;
  final String status;

  ConversationModel({
    required this.id,
    required this.participantIds,
    required this.professorInfo,
    this.lastMessage,
    this.unreadCount = 0,
    this.status = 'active',
  }) {
    if (participantIds.isEmpty) {
      throw ArgumentError('Conversation must have at least one participant');
    }
    if (participantIds.length > 10) {
      throw ArgumentError('Too many participants in conversation');
    }
    if (unreadCount < 0) {
      throw ArgumentError('Unread count cannot be negative');
    }
  }

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      professorInfo: ProfessorInfo.fromMap(data['professorInfo'] ?? {}),
      lastMessage: data['lastMessage'] != null
          ? LastMessage.fromMap(data['lastMessage'])
          : null,
      unreadCount: data['unreadCount'] ?? 0,
      status: data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'professorInfo': professorInfo.toMap(),
      'lastMessage': lastMessage?.toMap(),
      'unreadCount': unreadCount,
      'status': status,
    };
  }

  ConversationModel copyWith({
    String? id,
    List<String>? participantIds,
    ProfessorInfo? professorInfo,
    LastMessage? lastMessage,
    int? unreadCount,
    String? status,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      professorInfo: professorInfo ?? this.professorInfo,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ConversationModel(id: $id, professor: ${professorInfo.name}, unread: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}