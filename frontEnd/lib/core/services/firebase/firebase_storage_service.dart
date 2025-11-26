// lib/core/services/firebase/firebase_storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload image file
  Future<String> uploadImage(File file, String conversationId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final ref = _storage.ref('chat_images/$conversationId/$fileName');
      
      debugPrint('📤 Uploading image: $fileName');
      
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('✅ Image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload document file
  Future<String> uploadFile(File file, String conversationId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final ref = _storage.ref('chat_files/$conversationId/$fileName');
      
      debugPrint('📤 Uploading file: $fileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('✅ File uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading file: $e');
      rethrow;
    }
  }

  /// Delete file from storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      debugPrint('✅ File deleted: $fileUrl');
    } catch (e) {
      debugPrint('❌ Error deleting file: $e');
    }
  }

  /// Get file metadata
  Future<FullMetadata?> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } catch (e) {
      debugPrint('❌ Error getting file metadata: $e');
      return null;
    }
  }
}
