// ============================================================================
// CHAT PAGE - Firebase-powered Messaging with Professors
// ============================================================================
import 'package:flutter/material.dart';
import '../features/chat/presentation/pages/chat_list_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new Firebase-powered chat list page
    return const ChatListPage();
  }
}