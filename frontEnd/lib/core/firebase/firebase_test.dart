// lib/core/firebase/firebase_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class FirebaseTest {
  static Future<void> testConnection() async {
    try {
      // Ensure user is authenticated before testing Firestore
      await FirebaseService.instance.ensureAuthenticated();
      final userId = FirebaseService.instance.auth.currentUserId;
      debugPrint('🔐 Testing with user: $userId');

      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('connection_test').set({
        'message': 'Firebase connected successfully!',
        'timestamp': DateTime.now(),
        'platform': defaultTargetPlatform.toString(),
        'userId': userId,
      });

      debugPrint('✅ Firebase connection test passed!');

      // Test read
      final doc = await firestore.collection('test').doc('connection_test').get();
      if (doc.exists) {
        debugPrint('✅ Firestore read test passed!');
      }

      // Clean up test document
      await firestore.collection('test').doc('connection_test').delete();
      debugPrint('✅ Firebase test completed successfully!');

    } catch (e) {
      debugPrint('❌ Firebase test failed: $e');
      rethrow;
    }
  }

  static Future<void> createSampleData(String userId) async {
    try {
      // Ensure user is authenticated
      await FirebaseService.instance.ensureAuthenticated();
      final authenticatedUserId = FirebaseService.instance.auth.currentUserId!;
      debugPrint('🔐 Creating sample data for user: $authenticatedUserId');

      final firestore = FirebaseFirestore.instance;

      // Create sample notifications
      await firestore
          .collection('notifications')
          .doc(authenticatedUserId)
          .collection('items')
          .add({
            'title': 'Welcome to EPI App!',
            'message': 'Firebase integration is working perfectly.',
            'timestamp': DateTime.now(),
            'type': 'general',
            'read': false,
          });

      // Create sample conversation
      final conversationRef = await firestore
          .collection('chats')
          .doc(authenticatedUserId)
          .collection('conversations')
          .add({
            'participantIds': [authenticatedUserId, 'professor_demo'],
            'professorInfo': {
              'name': 'Dr. Demo Professor',
              'course': 'Firebase Integration',
              'avatar': 'assets/avatar.png',
              'building': 'Digital Lab',
            },
            'lastMessage': {
              'text': 'Welcome to Firebase chat!',
              'timestamp': DateTime.now(),
              'senderId': 'professor_demo',
            },
            'unreadCount': 1,
            'status': 'active',
          });

      // Add sample message
      await firestore
          .collection('messages')
          .doc(conversationRef.id)
          .collection('messages')
          .add({
            'senderId': 'professor_demo',
            'content': 'Welcome to Firebase chat!',
            'timestamp': DateTime.now(),
            'read': false,
            'type': 'text',
          });

      debugPrint('✅ Sample data created successfully!');

    } catch (e) {
      debugPrint('❌ Failed to create sample data: $e');
      rethrow;
    }
  }
}