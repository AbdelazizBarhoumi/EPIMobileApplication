// lib/features/chat/data/services/file_storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FileStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage and return download URL
  Future<String> uploadFile(
    File file,
    String folder, {
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child('$folder/$fileName');

      final uploadTask = ref.putFile(file);

      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      // Get download URL
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      
      debugPrint('✅ File uploaded successfully: $downloadURL');
      return downloadURL;
      
    } catch (e) {
      debugPrint('❌ Error uploading file: $e');
      rethrow;
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      debugPrint('✅ File deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting file: $e');
      rethrow;
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      debugPrint('❌ Error getting file metadata: $e');
      rethrow;
    }
  }
}