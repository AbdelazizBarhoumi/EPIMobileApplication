// lib/features/chat/presentation/controllers/conversation_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase/firebase_chat_service.dart';
import '../../../../core/services/onesignal_service.dart';
import '../../data/models/message_model.dart';
import '../../data/models/conversation_model.dart';

enum ConversationState { loading, loaded, error }

class ConversationController extends ChangeNotifier {
  final FirebaseChatService _chatService;
  final String _conversationId;
  final String _userId;

  ConversationController(this._conversationId, this._userId, FirebaseFirestore firestore, OneSignalService oneSignalService)
      : _chatService = FirebaseChatService(firestore, oneSignalService);

  ConversationState _state = ConversationState.loading;
  ConversationState get state => _state;

  String? _error;
  String? get error => _error;

  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  ConversationModel? _conversation;
  ConversationModel? get conversation => _conversation;

  Stream<List<MessageModel>>? _messageStream;
  StreamSubscription<List<MessageModel>>? _messageSubscription;

  void initialize() {
    _loadMessages();
  }

  void _loadMessages() {
    _state = ConversationState.loading;
    notifyListeners();

    try {
      _messageStream = _chatService.getMessages(_conversationId);

      // Listen to real-time updates
      _messageSubscription?.cancel();
      _messageSubscription = _messageStream!.listen(
        (messages) {
          if (!mounted) return;
          _messages = messages;
          _state = ConversationState.loaded;
          notifyListeners();
        },
        onError: (error) {
          if (!mounted) return;
          _error = error.toString();
          _state = ConversationState.error;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _state = ConversationState.error;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content, {MessageType type = MessageType.text}) async {
    if (content.trim().isEmpty && type == MessageType.text) {
      _error = 'Message content cannot be empty';
      notifyListeners();
      return;
    }

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _userId,
      content: content.trim(),
      timestamp: DateTime.now(),
      type: type,
      status: MessageStatus.sending,
    );

    try {
      // Optimistically add to UI at the end (chronological order)
      _messages.add(message);
      notifyListeners();

      // Send to Firebase
      await _chatService.sendMessage(_conversationId, message.copyWith(
        status: MessageStatus.sent,
      ));

      // Update status to delivered (optimistic)
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1 && mounted) {
        _messages[index] = message.copyWith(status: MessageStatus.delivered);
        notifyListeners();
      }
      
      // Clear any previous errors
      _error = null;
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      
      // Mark message as failed instead of removing it
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1 && mounted) {
        // Keep message in UI but show it failed
        _messages[index] = message.copyWith(status: MessageStatus.sending);
        _error = 'Failed to send message. Please check your connection.';
        notifyListeners();
        
        // Auto-retry after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            retryMessage(message);
          }
        });
      }
    }
  }

  /// Retry sending a failed message
  Future<void> retryMessage(MessageModel message) async {
    try {
      debugPrint('🔄 Retrying message: ${message.id}');
      
      // Update UI to show retrying
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1 && mounted) {
        _messages[index] = message.copyWith(status: MessageStatus.sending);
        notifyListeners();
      }

      // Attempt to send again
      await _chatService.sendMessage(_conversationId, message.copyWith(
        status: MessageStatus.sent,
      ));

      // Update status to delivered on success
      if (index != -1 && mounted) {
        _messages[index] = message.copyWith(status: MessageStatus.delivered);
        _error = null;
        notifyListeners();
      }
      
      debugPrint('✅ Message retry successful: ${message.id}');
    } catch (e) {
      debugPrint('❌ Message retry failed: $e');
      // Keep showing error, don't auto-retry again to avoid infinite loop
      if (mounted) {
        _error = 'Message send failed. Please try again manually.';
        notifyListeners();
      }
    }
  }

  /// Remove a failed message from the UI
  void removeMessage(String messageId) {
    _messages.removeWhere((m) => m.id == messageId);
    _error = null;
    notifyListeners();
  }

  Future<void> markMessagesAsRead() async {
    try {
      await _chatService.markMessagesAsRead(_conversationId, _userId);
      // The stream will automatically update the UI
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setConversation(ConversationModel conv) {
    _conversation = conv;
    notifyListeners();
  }

  void refresh() {
    _loadMessages();
  }

  bool _mounted = true;
  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    _messageSubscription?.cancel();
    super.dispose();
  }
}