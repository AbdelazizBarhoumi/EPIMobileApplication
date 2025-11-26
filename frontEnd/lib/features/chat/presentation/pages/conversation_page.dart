// lib/features/chat/presentation/pages/conversation_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/conversation_controller.dart';
import '../widgets/message_bubble.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/services/presence_service.dart';
import '../../../../core/services/onesignal_service.dart';

class ConversationPage extends StatefulWidget {
  final String conversationId;
  final String userId;
  final ConversationModel conversation;

  const ConversationPage({
    super.key,
    required this.conversationId,
    required this.userId,
    required this.conversation,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ConversationController _controller;
  late PresenceService _presenceService;
  
  // State management variables
  String? _errorMessage;
  bool _isInitialized = false;
  String _professorPresenceStatus = 'Checking...';
  DateTime? _lastSeen;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  void _initializeControllers() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final oneSignalService = Provider.of<OneSignalService>(context, listen: false);
      _controller = ConversationController(
        widget.conversationId,
        widget.userId,
        firestore,
        oneSignalService,
      );
      
      _controller.initialize();
      
      // Initialize presence service
      _presenceService = PresenceService();
      await _initializePresence();
      
      // Mark messages as read when conversation opens
      if (mounted) {
        _controller.markMessagesAsRead();
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize chat: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializePresence() async {
    try {
      await _presenceService.initializePresence();
      // Only proceed with presence listening if initialization succeeded
      _listenToTeacherPresence();
    } catch (e) {
      debugPrint('⚠️ Presence service initialization failed: $e');
      debugPrint('💡 To enable presence tracking:');
      debugPrint('   1. Go to Firebase Console → Realtime Database');
      debugPrint('   2. Create database if not exists');
      debugPrint('   3. Set rules to allow authenticated users');
      
      // Continue without presence - not critical for basic chat functionality
      if (mounted) {
        setState(() {
          _professorPresenceStatus = 'Offline'; // More accurate than 'Unknown'
        });
      }
    }
  }

  void _listenToTeacherPresence() {
    // Use actual professor ID from conversation data
    final teacherId = widget.conversation.professorInfo.id;
    
    _presenceService.getUserPresence(teacherId).listen((presenceData) {
      if (mounted) {
        setState(() {
          if (presenceData != null && presenceData['online'] == true) {
            _professorPresenceStatus = 'Online';
            _lastSeen = null;
          } else {
            _professorPresenceStatus = 'Offline';
            _getLastSeen(teacherId);
          }
        });
      }
    });
  }

  Future<void> _getLastSeen(String userId) async {
    try {
      _presenceService.getUserLastSeen(userId).listen((lastSeen) {
        if (mounted && lastSeen != null) {
          setState(() {
            _lastSeen = lastSeen;
            _professorPresenceStatus = _formatLastSeen(lastSeen);
          });
        }
      });
    } catch (e) {
      debugPrint('Failed to get last seen: $e');
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    await _controller.sendMessage(text);
    
    // Scroll to bottom after sending message (messages are in chronological order)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Simulate a teacher message for testing (writes directly to Firestore)
  void _simulateTeacherMessage() async {
    try {
      final teacherId = widget.conversation.professorInfo.id;
      final teacherName = widget.conversation.professorInfo.name;
      
      final testMessages = [
        "Hello! I received your message.",
        "That's a great question!",
        "Let me help you with that.",
        "Please check the course materials.",
        "Feel free to ask if you need clarification.",
        "I'll be available during office hours.",
      ];
      
      final randomMessage = testMessages[DateTime.now().millisecond % testMessages.length];
      
      // Create teacher message
      final teacherMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: teacherId,
        content: randomMessage,
        timestamp: DateTime.now(),
        type: MessageType.text,
        status: MessageStatus.sent,
      );
      
      // Write directly to Firestore
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.conversationId)
          .collection('messages')
          .doc(teacherMessage.id)
          .set(teacherMessage.toFirestore());
      
      // Update student's conversation with new last message
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.userId)
          .collection('conversations')
          .doc(widget.conversationId)
          .set({
            'lastMessage': {
              'text': randomMessage,
              'timestamp': Timestamp.fromDate(teacherMessage.timestamp),
              'senderId': teacherId,
            },
            'unreadCount': FieldValue.increment(1),
          }, SetOptions(merge: true));
      
      debugPrint('✅ TEST: Simulated teacher message from $teacherName');
      
      // Show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📨 Simulated message from $teacherName'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ TEST: Failed to simulate teacher message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to simulate message: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error state
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[900],
          title: Text(
            widget.conversation.professorInfo.name,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error: $_errorMessage',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isInitialized = false;
                  });
                  _initializeControllers();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading state
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[900],
          title: Text(
            widget.conversation.professorInfo.name,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.red[900],
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.conversation.professorInfo.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _professorPresenceStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: _professorPresenceStatus == 'Online' 
                            ? Colors.green[600] 
                            : Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          elevation: 1,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shadowColor: Colors.black12,
          actions: [
            // Test button to simulate teacher message
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.orange),
              tooltip: 'Simulate teacher message (TEST)',
              onPressed: () => _simulateTeacherMessage(),
            ),
          ],
        ),
        body: Consumer<ConversationController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                // Messages List
                Expanded(
                  child: controller.state == ConversationState.loading && controller.messages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : controller.messages.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            itemCount: controller.messages.length,
                            reverse: true,  // Show latest messages at bottom
                            itemBuilder: (context, index) {
                              // Reverse the index to show messages in correct order
                              final reversedIndex = controller.messages.length - 1 - index;
                              final message = controller.messages[reversedIndex];
                              return MessageBubble(
                                message: message,
                                isMe: message.senderId == widget.userId,
                              );
                            },
                            ),
                ),
              
                // Message Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer<ConversationController>(
                        builder: (context, controller, child) {
                          return FloatingActionButton(
                            onPressed: controller.state == ConversationState.loading
                                ? null
                                : _sendMessage,
                            backgroundColor: Colors.red[900],
                            mini: true,
                            child: controller.state == ConversationState.loading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to begin chatting',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}