// lib/core/firebase/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static String get _apiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get _projectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get _messagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get _appId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _apiKey,
    appId: '1:67907098202:web:f8bc28435a01e23fae6a63',
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    authDomain: '$_projectId.firebaseapp.com',
    databaseURL: 'https://$_projectId-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: '$_projectId.firebasestorage.app',
    measurementId: 'your-measurement-id',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    databaseURL: 'https://$_projectId-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: '$_projectId.firebasestorage.app',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _apiKey,
    appId: '1:67907098202:ios:f8bc28435a01e23fae6a63',
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    databaseURL: 'https://$_projectId-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: '$_projectId.firebasestorage.app',
    iosBundleId: 'com.epi.mobileApplicaition',
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: _apiKey,
    appId: '1:67907098202:macos:f8bc28435a01e23fae6a63',
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    databaseURL: 'https://$_projectId-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: '$_projectId.firebasestorage.app',
    iosBundleId: 'com.epi.mobileApplicaition',
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: _apiKey,
    appId: '1:67907098202:windows:f8bc28435a01e23fae6a63',
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    databaseURL: 'https://$_projectId-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: '$_projectId.firebasestorage.app',
  );
}