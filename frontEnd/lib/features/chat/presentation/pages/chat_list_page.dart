// lib/features/chat/presentation/pages/chat_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../controllers/chat_list_controller.dart';
import '../widgets/conversation_tile.dart';
import '../pages/conversation_page.dart';
import '../pages/new_chat_page.dart';
import '../../data/models/conversation_model.dart';
import '../../../../core/services/onesignal_service.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  ChatListController? _controller;
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() async {
    try {
      // Ensure Firebase is initialized
      final firebaseService = FirebaseService.instance;
      if (!firebaseService.isInitialized) {
        await firebaseService.initialize();
      }

      // Get authenticated user ID
      final userId = firebaseService.auth.currentUserId;
      if (userId == null) {
        // Try to authenticate anonymously
        await firebaseService.ensureAuthenticated();
        final newUserId = firebaseService.auth.currentUserId;
        if (newUserId == null) {
          setState(() {
            _errorMessage = 'Authentication failed. Please restart the app.';
          });
          return;
        }
      }

      final finalUserId = firebaseService.auth.currentUserId!;
      final oneSignalService = Provider.of<OneSignalService>(context, listen: false);
      _controller = ChatListController(finalUserId, FirebaseFirestore.instance, oneSignalService);
      _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize chat: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error state if initialization failed
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.red[900],
          title: const Text(
            "Messages",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[700],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                  _initializeController();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading state if controller is not ready
    if (_controller == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.red[900],
          title: const Text(
            "Messages",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _controller!,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.red[900],
          title: const Text(
            "Messages",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewChatPage()),
                );
              },
            ),
            Consumer<ChatListController>(
              builder: (context, controller, child) {
                if (controller.totalUnreadCount > 0) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Text(
                        '${controller.totalUnreadCount} new',
                        style: TextStyle(
                          color: Colors.red[900],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search professors or courses...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Chat List
            Expanded(
              child: Consumer<ChatListController>(
                builder: (context, controller, child) {
                  if (controller.state == ChatListState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.state == ChatListState.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load conversations',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.error ?? 'Unknown error',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredConversations = controller.conversations.where((conv) {
                    if (_searchQuery.isEmpty) return true;
                    final query = _searchQuery.toLowerCase();
                    return conv.professorInfo.name.toLowerCase().contains(query) ||
                           conv.professorInfo.course.toLowerCase().contains(query);
                  }).toList();

                  if (filteredConversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No conversations yet'
                                : 'No conversations found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Start a conversation with your teachers',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NewChatPage()),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('New Conversation'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[900],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => controller.refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = filteredConversations[index];
                        return ConversationTile(
                          conversation: conversation,
                          onTap: () => _openConversation(conversation),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewChatPage()),
            );
          },
          backgroundColor: Colors.red[900],
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _openConversation(ConversationModel conversation) {
    final userId = FirebaseService.instance.auth.currentUserId;
    if (userId == null) {
      // If no authenticated user, show authentication error
      setState(() {
        _errorMessage = 'User not authenticated. Please log in to access chat.';
      });
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationPage(
          conversationId: conversation.id,
          userId: userId,
          conversation: conversation,
        ),
      ),
    );
  }
}