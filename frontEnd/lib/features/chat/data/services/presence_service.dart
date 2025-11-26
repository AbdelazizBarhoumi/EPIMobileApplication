// lib/features/chat/data/services/presence_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class PresenceService {
  final FirebaseDatabase _database;
  final FirebaseAuth _auth;
  DatabaseReference? _myPresenceRef;
  DatabaseReference? _myLastSeenRef;

  PresenceService()
      : _database = FirebaseDatabase.instanceFor(
          app: FirebaseAuth.instance.app,
          databaseURL: 'https://epimobileapplication-14233-default-rtdb.europe-west1.firebasedatabase.app',
        ),
        _auth = FirebaseAuth.instance;

  /// Initialize presence tracking for current user
  Future<void> initializePresence() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Cannot initialize presence tracking.');
    }

    try {
      final userId = user.uid;
      _myPresenceRef = _database.ref('presence/$userId');
      _myLastSeenRef = _database.ref('lastSeen/$userId');

      // Test connection by attempting to write
      await _myPresenceRef!.set({
        'online': true,
        'lastChanged': {'.sv': 'timestamp'},
      });

      // Set up presence detection
      final connectedRef = _database.ref('.info/connected');
      connectedRef.onValue.listen((event) async {
        if (event.snapshot.value == true) {
          // User is online
          await _setOnlineStatus(true);
          
          // Set up offline handler
          await _myPresenceRef!.onDisconnect().set({
            'online': false,
            'lastChanged': {'.sv': 'timestamp'},
          });
          
          await _myLastSeenRef!.onDisconnect().set({'.sv': 'timestamp'});
        }
      });

      debugPrint('✅ Presence tracking initialized for user: $userId');
    } catch (e) {
      debugPrint('❌ Error initializing presence: $e');
      // Rethrow to let caller handle the error
      throw Exception('Failed to initialize presence tracking. Firebase Realtime Database may not be configured. Error: $e');
    }
  }

  /// Set online/offline status manually
  Future<void> _setOnlineStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user == null || _myPresenceRef == null) return;

    try {
      await _myPresenceRef!.set({
        'online': isOnline,
        'lastChanged': {'.sv': 'timestamp'},
      });

      if (!isOnline) {
        await _myLastSeenRef!.set({'.sv': 'timestamp'});
      }
    } catch (e) {
      debugPrint('❌ Error setting online status: $e');
    }
  }

  /// Set user offline manually (call when app goes to background)
  Future<void> setOffline() async {
    await _setOnlineStatus(false);
  }

  /// Set user online manually (call when app comes to foreground)
  Future<void> setOnline() async {
    await _setOnlineStatus(true);
  }

  /// Get presence status for a specific user
  Stream<Map<String, dynamic>?> getUserPresence(String userId) {
    return _database.ref('presence/$userId').onValue.map((event) {
      if (event.snapshot.value == null) return null;
      final data = event.snapshot.value;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    });
  }

  /// Get last seen timestamp for a specific user
  Stream<DateTime?> getUserLastSeen(String userId) {
    return _database.ref('lastSeen/$userId').onValue.map((event) {
      if (event.snapshot.value == null) return null;
      final timestamp = event.snapshot.value as num;
      return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    });
  }

  /// Get online status for multiple users
  Future<Map<String, bool>> getMultipleUserPresence(List<String> userIds) async {
    final Map<String, bool> presenceMap = {};
    
    for (final userId in userIds) {
      try {
        final snapshot = await _database.ref('presence/$userId/online').get();
        presenceMap[userId] = snapshot.value == true;
      } catch (e) {
        presenceMap[userId] = false;
      }
    }
    
    return presenceMap;
  }

  /// Clean up presence tracking
  void dispose() {
    _myPresenceRef?.onDisconnect().cancel();
    _myLastSeenRef?.onDisconnect().cancel();
  }
}