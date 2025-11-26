// lib/core/firebase/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/firebase/firebase_messaging_service.dart';
import 'firebase_options.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  late final FirebaseMessagingService? _messagingService;
  FirebaseMessagingService? get messaging => _messagingService;
  
  late final FirebaseAuthService _authService;
  FirebaseAuthService get auth => _authService;

  /// Initialize Firebase services
  Future<void> initialize() async {
    try {
      // Check if Firebase is already initialized (handles hot restart)
      if (Firebase.apps.isNotEmpty) {
        debugPrint('✅ Firebase already initialized (using existing app)');
        
        // Still need to initialize services if not done yet
        if (!_initialized) {
          _authService = FirebaseAuthService.instance;
          
          if (!kIsWeb) {
            _messagingService = FirebaseMessagingService();
            await _messagingService!.initialize();
          } else {
            _messagingService = null;
          }
          
          _initialized = true;
          debugPrint('✅ Firebase services initialized');
        }
        return;
      }

      // First time initialization
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized for the first time');

      // Initialize Firebase Auth Service
      _authService = FirebaseAuthService.instance;

      // Initialize Firebase Messaging Service (skip on web for now)
      if (!kIsWeb) {
        _messagingService = FirebaseMessagingService();
        await _messagingService!.initialize();
      } else {
        _messagingService = null;
      }

      _initialized = true;
      debugPrint('✅ Firebase initialization complete');
      debugPrint('   Auth status: ${_authService.isAuthenticated}');
      if (_authService.isAuthenticated) {
        debugPrint('   Current user: ${_authService.currentUserId}');
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize Firebase: $e');
      
      // If it's a duplicate app error, Firebase is already initialized
      if (e.toString().contains('duplicate-app')) {
        debugPrint('⚠️ Firebase already exists, using existing instance');
        
        if (!_initialized) {
          _authService = FirebaseAuthService.instance;
          
          if (!kIsWeb) {
            _messagingService = FirebaseMessagingService();
            await _messagingService!.initialize();
          } else {
            _messagingService = null;
          }
          
          _initialized = true;
        }
        return; // Don't rethrow, we can continue
      }
      
      rethrow;
    }
  }
  
  /// Ensure user is authenticated (sign in anonymously if needed)
  /// Call this before accessing Firestore
  Future<void> ensureAuthenticated() async {
    if (!_authService.isAuthenticated) {
      try {
        debugPrint('User not authenticated, signing in anonymously...');
        await _authService.signInAnonymously();
        debugPrint('Anonymous sign-in successful: ${_authService.currentUserId}');
      } catch (e) {
        debugPrint('⚠️ Anonymous authentication failed: $e');
        debugPrint('');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('❌ FIREBASE AUTHENTICATION NOT CONFIGURED');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('');
        debugPrint('To fix this, enable Anonymous Authentication:');
        debugPrint('1. Go to: https://console.firebase.google.com');
        debugPrint('2. Select project: epi-mobile-application');
        debugPrint('3. Go to: Authentication → Sign-in method');
        debugPrint('4. Enable: Anonymous');
        debugPrint('5. Click: Save');
        debugPrint('');
        debugPrint('Then restart the app.');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('');
        // Continue without authentication for now
        // The app will run but Firestore operations will fail until auth is enabled
      }
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    return await _messagingService?.getToken();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messagingService?.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messagingService?.unsubscribeFromTopic(topic);
  }
}