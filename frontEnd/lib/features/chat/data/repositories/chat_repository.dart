// lib/features/chat/data/repositories/chat_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/onesignal_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRepository {
  Stream<List<ConversationModel>> getConversations(String userId);
  Stream<List<MessageModel>> getMessages(String conversationId);
  Future<void> sendMessage(String conversationId, MessageModel message);
  Future<void> markMessagesAsRead(String conversationId, String userId);
  Future<String> createConversation(String userId, ConversationModel conversation);
  Future<void> updateConversationLastMessage(String conversationId, MessageModel lastMessage);
  Future<void> addReaction(String conversationId, String messageId, String emoji, String userId);
  Future<void> removeReaction(String conversationId, String messageId, String emoji, String userId);
  Future<void> setTyping(String conversationId, String userId, bool isTyping);
  Stream<Map<String, bool>> getTypingStatus(String conversationId);
}

class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final OneSignalService _oneSignalService;

  FirebaseChatRepository(this._firestore, this._oneSignalService) : _auth = FirebaseAuth.instance;

  @override
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _firestore
        .collection('chats')
        .doc(userId)
        .collection('conversations')
        .orderBy('lastMessage.timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ConversationModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('messages')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)  // Changed to false for chronological order
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> sendMessage(String conversationId, MessageModel message) async {
    try {
      // Validate authentication
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in to send messages.');
      }
      
      // Validate inputs
      if (conversationId.isEmpty) {
        throw ArgumentError('Conversation ID cannot be empty');
      }

      // Step 1: Add message to messages collection
      debugPrint('📝 Step 1: Adding message to messages collection...');
      final messageRef = _firestore
          .collection('messages')
          .doc(conversationId)
          .collection('messages')
          .doc(message.id);

      await messageRef.set(message.toFirestore());
      debugPrint('✅ Message added successfully');

      // Step 2: Get conversation participants
      debugPrint('📝 Step 2: Getting conversation participants...');
      final senderConvRef = _firestore
          .collection('chats')
          .doc(message.senderId)
          .collection('conversations')
          .doc(conversationId);

      final convDoc = await senderConvRef.get();
      if (!convDoc.exists) {
        throw Exception('Conversation not found');
      }

      final convData = convDoc.data()!;
      debugPrint('📋 Conversation data: $convData');
      debugPrint('📋 Auth UID: ${currentUser.uid}');
      debugPrint('📋 Sender ID: ${message.senderId}');
      
      final participantIds = List<String>.from(convData['participantIds'] ?? []);
      debugPrint('📋 Participant IDs: $participantIds');
      
      if (participantIds.isEmpty) {
        throw Exception('No participants found in conversation');
      }

      // Prepare last message data
      final lastMessageData = {
        'text': message.content,
        'timestamp': Timestamp.fromDate(message.timestamp),
        'senderId': message.senderId,
      };

      // Step 3: Update only the sender's conversation
      // Note: Other participants' conversations will be updated by Cloud Functions or when they open the chat
      debugPrint('📝 Step 3: Updating sender conversation...');
      
      final senderConversationRef = _firestore
          .collection('chats')
          .doc(message.senderId)
          .collection('conversations')
          .doc(conversationId);

      await senderConversationRef.set({
        'lastMessage': lastMessageData,
      }, SetOptions(merge: true));
      
      debugPrint('✅ Sender conversation updated successfully!');

      // Step 4: Send notifications to other participants
      debugPrint('📝 Step 4: Sending notifications to other participants...');
      final otherParticipantIds = participantIds.where((id) => id != message.senderId).toList();
      
      for (final participantId in otherParticipantIds) {
        final playerId = await _oneSignalService.getUserPlayerId(participantId);
        if (playerId != null) {
          await _oneSignalService.sendNotification(
            playerId: playerId,
            title: 'New Message',
            message: message.content.length > 50 
                ? '${message.content.substring(0, 50)}...' 
                : message.content,
            additionalData: {
              'type': 'chat',
              'conversationId': conversationId,
              'senderId': message.senderId,
            },
          );
          debugPrint('✅ Notification sent to participant: $participantId');
        } else {
          debugPrint('⚠️ No player ID found for participant: $participantId');
        }
      }
      
      debugPrint('✅ Message sending completed successfully!');
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      final batch = _firestore.batch();

      // Get all unread messages (remove the isNotEqualTo filter to avoid index requirement)
      final messages = await _firestore
          .collection('messages')
          .doc(conversationId)
          .collection('messages')
          .where('read', isEqualTo: false)
          .get();

      // Filter out current user's messages in code (not in query)
      for (final doc in messages.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String?;
        
        // Only mark OTHER user's messages as read
        if (senderId != null && senderId != userId) {
          batch.update(doc.reference, {
            'read': true,
            'status': MessageStatus.read.name,
          });
        }
      }

      // Reset unread count for user
      final conversationRef = _firestore
          .collection('chats')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId);

      batch.update(conversationRef, {'unreadCount': 0});

      await batch.commit();
    } catch (e) {
      debugPrint('❌ Error marking messages as read: $e');
      // Don't rethrow - this is not critical
    }
  }

  @override
  Future<String> createConversation(String userId, ConversationModel conversation) async {
    final docRef = await _firestore
        .collection('chats')
        .doc(userId)
        .collection('conversations')
        .add(conversation.toFirestore());

    return docRef.id;
  }

  @override
  Future<void> updateConversationLastMessage(String conversationId, MessageModel lastMessage) async {
    // This method is used internally by sendMessage, but can be used separately if needed
    // Update for all participants
    final batch = _firestore.batch();
    // Note: In a real app, you'd get all participant IDs and update each
    // For now, assuming we know the user IDs

    await batch.commit();
  }

  @override
  Future<void> addReaction(String conversationId, String messageId, String emoji, String userId) async {
    final messageRef = _firestore
        .collection('messages')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    await messageRef.update({
      'reactions.$emoji': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> removeReaction(String conversationId, String messageId, String emoji, String userId) async {
    final messageRef = _firestore
        .collection('messages')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    await messageRef.update({
      'reactions.$emoji': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> setTyping(String conversationId, String userId, bool isTyping) async {
    final typingRef = _firestore
        .collection('typing')
        .doc(conversationId)
        .collection('users')
        .doc(userId);

    if (isTyping) {
      await typingRef.set({
        'isTyping': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await typingRef.delete();
    }
  }

  @override
  Stream<Map<String, bool>> getTypingStatus(String conversationId) {
    return _firestore
        .collection('typing')
        .doc(conversationId)
        .collection('users')
        .snapshots()
        .map((snapshot) {
      final typingUsers = <String, bool>{};
      for (final doc in snapshot.docs) {
        typingUsers[doc.id] = doc.data()['isTyping'] ?? false;
      }
      return typingUsers;
    });
  }
}