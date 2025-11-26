// lib/core/services/firebase/firebase_chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/chat/data/models/conversation_model.dart';
import '../../../features/chat/data/models/message_model.dart';
import '../../../features/chat/data/repositories/chat_repository.dart';
import '../onesignal_service.dart';

class FirebaseChatService {
  final ChatRepository _repository;

  FirebaseChatService(FirebaseFirestore firestore, OneSignalService oneSignalService)
      : _repository = FirebaseChatRepository(firestore, oneSignalService);

  /// Get real-time conversations stream for a user
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _repository.getConversations(userId);
  }

  /// Get real-time messages stream for a conversation
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _repository.getMessages(conversationId);
  }

  /// Send a message to a conversation
  Future<void> sendMessage(String conversationId, MessageModel message) async {
    await _repository.sendMessage(conversationId, message);
  }

  /// Mark messages as read in a conversation
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    await _repository.markMessagesAsRead(conversationId, userId);
  }

  /// Create a new conversation
  Future<String> createConversation(String userId, ConversationModel conversation) async {
    return await _repository.createConversation(userId, conversation);
  }

  /// Get total unread messages count across all conversations
  Stream<int> getTotalUnreadCount(String userId) {
    return getConversations(userId).map((conversations) =>
        conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount));
  }

  /// Get conversation by ID
  Future<ConversationModel?> getConversation(String userId, String conversationId) async {
    final conversations = await getConversations(userId).first;
    return conversations.where((conv) => conv.id == conversationId).firstOrNull;
  }
}