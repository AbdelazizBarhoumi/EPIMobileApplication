// lib/features/chat/presentation/pages/new_chat_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/teacher_service.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../../../../core/api_client.dart';
import '../../data/models/conversation_model.dart';
import 'conversation_page.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  late TeacherService _teacherService;
  List<Teacher> _allTeachers = [];
  List<Teacher> _filteredTeachers = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      final apiClient = context.read<ApiClient>();
      _teacherService = TeacherService(apiClient);
      await _loadTeachers();
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTeachers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      debugPrint('🔍 Loading teachers...');
      final teachers = await _teacherService.getMyTeachers();
      debugPrint('✅ Loaded ${teachers.length} teachers');
      
      setState(() {
        _allTeachers = teachers;
        _filteredTeachers = teachers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading teachers: $e');
      setState(() {
        _error = 'Could not connect to server.\nPlease check your network connection.';
        _isLoading = false;
      });
    }
  }

  void _filterTeachers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTeachers = _allTeachers;
      } else {
        _filteredTeachers = _allTeachers.where((teacher) {
          final nameLower = teacher.name.toLowerCase();
          final coursesLower = teacher.courses.map((c) => c.name.toLowerCase()).join(' ');
          final deptLower = (teacher.department ?? '').toLowerCase();
          final queryLower = query.toLowerCase();
          
          return nameLower.contains(queryLower) ||
                 coursesLower.contains(queryLower) ||
                 deptLower.contains(queryLower);
        }).toList();
      }
    });
  }

  Future<void> _startConversation(Teacher teacher) async {
    try {
      final userId = FirebaseService.instance.auth.currentUserId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required')),
        );
        return;
      }

      // Check if conversation already exists
      final existingConversations = await FirebaseFirestore.instance
          .collection('chats')
          .doc(userId)
          .collection('conversations')
          .where('participantIds', arrayContains: 'teacher_${teacher.id}')
          .limit(1)
          .get();

      ConversationModel conversation;
      String conversationId;

      if (existingConversations.docs.isNotEmpty) {
        // Use existing conversation
        conversation = ConversationModel.fromFirestore(existingConversations.docs.first);
        conversationId = conversation.id;
      } else {
        // Create new conversation
        conversation = ConversationModel(
          id: '',
          participantIds: [userId, 'teacher_${teacher.id}'],
          professorInfo: ProfessorInfo(
            id: 'teacher_${teacher.id}',
            name: teacher.name,
            course: teacher.courses.isNotEmpty ? teacher.courses.first.name : 'General',
            avatar: '', // Default avatar
            building: teacher.officeLocation ?? 'Campus',
          ),
          lastMessage: LastMessage(
            text: 'Start a conversation',
            timestamp: DateTime.now(),
            senderId: userId,
          ),
          unreadCount: 0,
          status: 'active',
        );

        // Save to Firestore
        final docRef = await FirebaseFirestore.instance
            .collection('chats')
            .doc(userId)
            .collection('conversations')
            .add(conversation.toFirestore());

        conversationId = docRef.id;
        conversation = ConversationModel(
          id: conversationId,
          participantIds: conversation.participantIds,
          professorInfo: conversation.professorInfo,
          lastMessage: conversation.lastMessage,
          unreadCount: conversation.unreadCount,
          status: conversation.status,
        );
      }

      // Navigate to conversation
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationPage(
              conversationId: conversationId,
              userId: userId,
              conversation: conversation,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Conversation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
              onChanged: _filterTeachers,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search teachers, courses...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _filterTeachers('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),

          // Teachers List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              const Text(
                                'Connection Error',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _error,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _loadTeachers,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[900],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredTeachers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty
                                      ? 'No teachers found'
                                      : 'No teachers match your search',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredTeachers.length,
                            itemBuilder: (context, index) {
                              final teacher = _filteredTeachers[index];
                              return _buildTeacherCard(teacher);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(Teacher teacher) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _startConversation(teacher),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red[900],
                child: Text(
                  teacher.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Teacher Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${teacher.displayTitle} • ${teacher.displayDepartment}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (teacher.courses.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: teacher.courses.take(2).map((course) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              course.code,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[900],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
