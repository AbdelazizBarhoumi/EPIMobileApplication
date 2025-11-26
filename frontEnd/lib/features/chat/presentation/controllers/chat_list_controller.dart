// lib/features/chat/presentation/controllers/chat_list_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase/firebase_chat_service.dart';
import '../../../../core/services/onesignal_service.dart';
import '../../data/models/conversation_model.dart';

enum ChatListState { loading, loaded, error }

class ChatListController extends ChangeNotifier {
  final FirebaseChatService _chatService;
  final String _userId;

  ChatListController(this._userId, FirebaseFirestore firestore, OneSignalService oneSignalService)
      : _chatService = FirebaseChatService(firestore, oneSignalService);

  ChatListState _state = ChatListState.loading;
  ChatListState get state => _state;

  String? _error;
  String? get error => _error;

  List<ConversationModel> _conversations = [];
  List<ConversationModel> get conversations => _conversations;

  int get totalUnreadCount => _conversations.fold<int>(
      0, (sum, conv) => sum + conv.unreadCount);

  Stream<List<ConversationModel>>? _conversationStream;
  StreamSubscription<List<ConversationModel>>? _conversationSubscription;

  void initialize() {
    _loadConversations();
  }

  void _loadConversations() {
    _state = ChatListState.loading;
    notifyListeners();

    try {
      _conversationStream = _chatService.getConversations(_userId);

      // Listen to real-time updates
      _conversationSubscription?.cancel();
      _conversationSubscription = _conversationStream!.listen(
        (conversations) {
          if (!mounted) return;
          _conversations = conversations;
          _state = ChatListState.loaded;
          notifyListeners();
        },
        onError: (error) {
          if (!mounted) return;
          _error = error.toString();
          _state = ChatListState.error;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _state = ChatListState.error;
      notifyListeners();
    }
  }

  Future<String> createConversation(ConversationModel conversation) async {
    try {
      final conversationId = await _chatService.createConversation(_userId, conversation);
      // The stream will automatically update the UI
      return conversationId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  ConversationModel? getConversationById(String conversationId) {
    return _conversations.where((conv) => conv.id == conversationId).firstOrNull;
  }

  void refresh() {
    _loadConversations();
  }

  bool _mounted = true;
  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    _conversationSubscription?.cancel();
    super.dispose();
  }
}