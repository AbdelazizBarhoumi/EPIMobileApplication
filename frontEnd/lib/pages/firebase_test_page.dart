// lib/pages/firebase_test_page.dart
import 'package:flutter/material.dart';
import '../core/firebase/firebase_test.dart';
import '../core/firebase/firebase_service.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  String _status = 'Ready to test Firebase';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Firebase connection...';
    });

    try {
      await FirebaseTest.testConnection();
      setState(() {
        _status = '✅ Firebase connection successful!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Firebase connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createSampleData() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating sample data...';
    });

    try {
      final userId = FirebaseService.instance.auth.currentUserId ?? 'anonymous';
      await FirebaseTest.createSampleData(userId);
      setState(() {
        _status = '✅ Sample data created successfully!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Failed to create sample data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Colors.red[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Firebase Connection'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _createSampleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Sample Data'),
            ),
            const SizedBox(height: 30),
            const Text(
              '📊 Check Firebase Console:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Firestore Database → Data tab\n'
              '• Look for collections: notifications, chats, messages\n'
              '• Check if test documents appear',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              '🔧 If tests fail:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Check internet connection\n'
              '• Verify firebase_options.dart values\n'
              '• Check google-services.json placement\n'
              '• Ensure Firestore security rules allow access',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}