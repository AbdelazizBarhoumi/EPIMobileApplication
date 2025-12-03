// lib/features/notifications/data/services/admin_notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/notification_model.dart';

/// Admin service for sending notifications to multiple users
class AdminNotificationService {
  final FirebaseFirestore _firestore;
  
  // Get API base URL from environment
  static String get _apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';

  AdminNotificationService(this._firestore);

  /// Send notification to a single user
  Future<void> sendToUser({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority? priority,
    String? actionUrl,
    DateTime? expiryDate,
    String? senderId,
    String? senderName,
    Map<String, dynamic>? metadata,
  }) async {
    debugPrint('🚀 [ADMIN] Starting sendToUser');
    debugPrint('📧 [ADMIN] Target userId: $userId');
    debugPrint('📝 [ADMIN] Title: $title');
    debugPrint('💬 [ADMIN] Message: $message');
    debugPrint('🏷️ [ADMIN] Type: $type');
    debugPrint('⚡ [ADMIN] Priority: ${priority ?? type.defaultPriority}');
    
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      priority: priority ?? type.defaultPriority,
      actionUrl: actionUrl,
      expiryDate: expiryDate,
      senderId: senderId,
      senderName: senderName,
      targetType: NotificationTarget.individual,
      targetIds: [userId],
      metadata: metadata,
    );
    
    debugPrint('📦 [ADMIN] Created notification with ID: ${notification.id}');
    
    try {
      final docPath = 'notifications/$userId/items';
      debugPrint('🔗 [ADMIN] Writing to Firestore path: $docPath');
      
      await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('items')
          .add(notification.toFirestore());
          
      debugPrint('✅ [ADMIN] Successfully sent notification to user $userId');
      
      // Log the notification send event
      await _logNotificationSent(
        notificationId: notification.id,
        targetType: 'individual',
        targetCount: 1,
        successCount: 1,
        failureCount: 0,
        type: type.toString(),
        priority: (priority ?? type.defaultPriority).toString(),
      );
    } catch (e) {
      debugPrint('❌ [ADMIN] Error sending notification: $e');
      
      // Log the failure
      await _logNotificationSent(
        notificationId: notification.id,
        targetType: 'individual',
        targetCount: 1,
        successCount: 0,
        failureCount: 1,
        type: type.toString(),
        priority: (priority ?? type.defaultPriority).toString(),
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Send notification to a specific class/group
  Future<Map<String, dynamic>> sendToClass({
    required String classId,
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority? priority,
    String? actionUrl,
    DateTime? expiryDate,
    String? senderId,
    String? senderName,
    Map<String, dynamic>? metadata,
  }) async {
    debugPrint('🏦 [ADMIN] Starting sendToClass');
    debugPrint('🏷️ [ADMIN] Class ID: $classId');
    
    // Get students from MySQL backend API for specific class
    debugPrint('🔗 [ADMIN] Fetching students for class $classId from MySQL backend...');
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/students?class_id=$classId'), // Laravel backend
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      debugPrint('📡 [ADMIN] API Response Status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        debugPrint('❌ [ADMIN] Failed to fetch students for class $classId: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to fetch students from backend',
          'targetCount': 0,
          'successCount': 0,
          'failureCount': 1,
        };
      }
      
      final responseData = json.decode(response.body);
      final List<dynamic> studentsData = responseData is List ? responseData : responseData['data'] ?? [];
      
      final studentIds = studentsData.map((student) => 
        (student['id']?.toString() ?? student['student_id']?.toString() ?? '')
      ).where((id) => id.isNotEmpty).toList();
      
      debugPrint('📄 [ADMIN] Found ${studentIds.length} students in class $classId');
      debugPrint('👥 [ADMIN] Student IDs: $studentIds');

      if (studentIds.isEmpty) {
        debugPrint('⚠️ [ADMIN] No students found in class $classId');
        return {
          'success': false,
          'message': 'No students found in class',
          'targetCount': 0,
          'successCount': 0,
          'failureCount': 0,
        };
      }

      return await sendToMultipleUsers(
        userIds: studentIds,
        title: title,
        message: message,
        type: type,
        priority: priority,
        actionUrl: actionUrl,
        expiryDate: expiryDate,
        senderId: senderId,
        senderName: senderName,
        metadata: {...?metadata, 'classId': classId},
        targetType: NotificationTarget.classGroup,
      );
    } catch (e) {
      debugPrint('❌ [ADMIN] Error fetching students from backend: $e');
      return {
        'success': false,
        'message': 'Error fetching students from backend: $e',
        'targetCount': 0,
        'successCount': 0,
        'failureCount': 1,
      };
    }
  }

  /// Send notification to multiple classes
  Future<Map<String, dynamic>> sendToMultipleClasses({
    required List<String> classIds,
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority? priority,
    String? actionUrl,
    DateTime? expiryDate,
    String? senderId,
    String? senderName,
    Map<String, dynamic>? metadata,
  }) async {
    debugPrint('🏫 [ADMIN] Starting sendToMultipleClasses');
    debugPrint('📋 [ADMIN] Class IDs: $classIds');
    
    final allStudentIds = <String>{};

    // Fetch students for each class from MySQL backend
    for (final classId in classIds) {
      try {
        debugPrint('🔗 [ADMIN] Fetching students for class $classId from MySQL backend...');
        final response = await http.get(
          Uri.parse('$_apiBaseUrl/api/students?class_id=$classId'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 30));
        
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final List<dynamic> studentsData = responseData is List ? responseData : responseData['data'] ?? [];
          
          final studentIds = studentsData.map((student) => 
            (student['id']?.toString() ?? student['student_id']?.toString() ?? '')
          ).where((id) => id.isNotEmpty);
          
          allStudentIds.addAll(studentIds);
          debugPrint('📄 [ADMIN] Added ${studentIds.length} students from class $classId');
        } else {
          debugPrint('❌ [ADMIN] Failed to fetch students for class $classId: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ [ADMIN] Error fetching students for class $classId: $e');
      }
    }

    debugPrint('👥 [ADMIN] Total unique students across all classes: ${allStudentIds.length}');

    return await sendToMultipleUsers(
      userIds: allStudentIds.toList(),
      title: title,
      message: message,
      type: type,
      priority: priority,
      actionUrl: actionUrl,
      expiryDate: expiryDate,
      senderId: senderId,
      senderName: senderName,
      metadata: {...?metadata, 'classIds': classIds},
      targetType: NotificationTarget.classGroup,
    );
  }

  /// Get all majors from MySQL backend
  Future<List<Map<String, dynamic>>> getMajors() async {
    try {
      debugPrint('🎓 [ADMIN] Fetching majors from MySQL backend...');
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/majors'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> majorsData = responseData['data'] ?? [];
        debugPrint('📊 [ADMIN] Found ${majorsData.length} majors');
        
        return majorsData.map((major) => {
          'id': major['id'],
          'name': major['name'],
          'code': major['code'],
          'department': major['department'],
          'students_count': major['students']?.length ?? 0,
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ [ADMIN] Error fetching majors: $e');
      return [];
    }
  }

  /// Send notification to students by major
  Future<Map<String, dynamic>> sendToMajor({
    required int majorId,
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority? priority,
    String? actionUrl,
    DateTime? expiryDate,
    String? senderId,
    String? senderName,
    Map<String, dynamic>? metadata,
  }) async {
    debugPrint('🎓 [ADMIN] Starting sendToMajor for major ID: $majorId');
    
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/students?major_id=$majorId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Failed to fetch students for major',
          'targetCount': 0,
          'successCount': 0,
          'failureCount': 1,
        };
      }
      
      final responseData = json.decode(response.body);
      final List<dynamic> studentsData = responseData['data'] ?? [];
      
      final studentIds = studentsData.map((student) => 
        (student['id']?.toString() ?? '')
      ).where((id) => id.isNotEmpty).toList();
      
      debugPrint('📊 [ADMIN] Found ${studentIds.length} students in major $majorId');
      
      if (studentIds.isEmpty) {
        return {
          'success': false,
          'message': 'No students found in this major',
          'targetCount': 0,
          'successCount': 0,
          'failureCount': 0,
        };
      }
      
      // Log major information
      final majorName = studentsData.isNotEmpty ? studentsData[0]['major_name'] : 'Unknown';
      debugPrint('🎓 [ADMIN] Sending to major: $majorName');

      return await sendToMultipleUsers(
        userIds: studentIds,
        title: title,
        message: message,
        type: type,
        priority: priority,
        actionUrl: actionUrl,
        expiryDate: expiryDate,
        senderId: senderId,
        senderName: senderName,
        metadata: {...?metadata, 'majorId': majorId, 'majorName': majorName},
        targetType: NotificationTarget.classGroup, // Using classGroup for major
      );
    } catch (e) {
      debugPrint('❌ [ADMIN] Error in sendToMajor: $e');
      return {
        'success': false,
        'message': 'Error sending to major: $e',
        'targetCount': 0,
        'successCount': 0,
        'failureCount': 1,
      };
    }
  }

  /// Get detailed information about a specific student
  Future<Map<String, dynamic>?> getStudentDetails(String studentId) async {
    try {
      debugPrint('👤 [ADMIN] Fetching details for student: $studentId');
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/students/$studentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final studentData = responseData['data'];
        
        debugPrint('📄 [ADMIN] Student details: ${studentData['name']} (${studentData['major']['name']})');
        
        return {
          'id': studentData['id'],
          'student_id': studentData['student_id'],
          'name': studentData['name'],
          'email': studentData['email'],
          'phone': studentData['phone'],
          'major': studentData['major'],
          'year': studentData['year'],
          'class_id': studentData['class_id'],
          'gpa': studentData['gpa'],
          'status': studentData['status'],
          'attendance_percentage': studentData['attendance_percentage'],
          'courses_count': studentData['courses_count'],
          'clubs_count': studentData['clubs_count'],
        };
      }
      return null;
    } catch (e) {
      debugPrint('❌ [ADMIN] Error fetching student details: $e');
      return null;
    }
  }

  /// Send notification to ALL students
  Future<Map<String, dynamic>> sendToAllStudents({
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority? priority,
    String? actionUrl,
    DateTime? expiryDate,
    String? senderId,
    String? senderName,
    Map<String, dynamic>? metadata,
  }) async {
    debugPrint('🌐 [ADMIN] Starting sendToAllStudents');
    debugPrint('📝 [ADMIN] Title: $title');
    debugPrint('💬 [ADMIN] Message: $message');
    
    // Fetch students from MySQL backend API
    debugPrint('🔗 [ADMIN] Fetching students from MySQL backend API...');
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/students'), // Laravel backend
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      debugPrint('📡 [ADMIN] API Response Status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        debugPrint('❌ [ADMIN] Failed to fetch students from backend: ${response.statusCode}');
        debugPrint('📄 [ADMIN] Response body: ${response.body}');
        
        // Fallback: Log the issue but continue (you can implement backup logic here)
        debugPrint('🔄 [ADMIN] Backend unavailable, but logging the attempt...');
        
        return {
          'success': false,
          'message': 'Backend server is unavailable. Students count: Unknown',
          'targetCount': 0,
          'successCount': 0,
          'failureCount': 1,
        };
      }
      
      final responseData = json.decode(response.body);
      final List<dynamic> studentsData = responseData is List ? responseData : responseData['data'] ?? [];
      
      // Extract student IDs from backend response
      final studentIds = studentsData.map((student) => 
        (student['id']?.toString() ?? student['student_id']?.toString() ?? '')
      ).where((id) => id.isNotEmpty).toList();
      
      debugPrint('📊 [ADMIN] Found ${studentIds.length} students from MySQL backend');
      
      // Log sample student data for debugging
      if (studentsData.isNotEmpty) {
        final sampleStudent = studentsData.first;
        debugPrint('👤 [ADMIN] Sample student: ${sampleStudent['name']} (${sampleStudent['student_id']}) - Major: ${sampleStudent['major_name'] ?? sampleStudent['major']?['name']}');
      }
      
      if (studentIds.isEmpty) {
        debugPrint('⚠️ [ADMIN] No students found in MySQL database!');
        debugPrint('💡 [ADMIN] Solution: Check backend API endpoint or add students to MySQL database');
        return {
          'success': false,
          'message': 'No students found in MySQL database',
          'targetCount': 0,
          'successCount': 0,
          'failureCount': 0,
        };
      }
      
      debugPrint('🎯 [ADMIN] Broadcasting to ALL students from MySQL');

      return await sendToMultipleUsers(
        userIds: studentIds,
        title: title,
        message: message,
        type: type,
        priority: priority,
        actionUrl: actionUrl,
        expiryDate: expiryDate,
        senderId: senderId,
        senderName: senderName,
        metadata: metadata,
        targetType: NotificationTarget.allStudents,
      );
    } catch (e) {
      debugPrint('❌ [ADMIN] Error fetching students from backend: $e');
      return {
        'success': false,
        'message': 'Error fetching students from backend: $e',
        'targetCount': 0,
        'successCount': 0,
        'failureCount': 1,
      };
    }
  }

  /// Send notification to multiple specific users
  Future<Map<String, dynamic>> sendToMultipleUsers({
    required List<String> userIds,
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority? priority,
    String? actionUrl,
    DateTime? expiryDate,
    String? senderId,
    String? senderName,
    Map<String, dynamic>? metadata,
    NotificationTarget? targetType,
  }) async {
    debugPrint('👥 [ADMIN] Starting sendToMultipleUsers');
    debugPrint('📊 [ADMIN] Target user count: ${userIds.length}');
    debugPrint('👤 [ADMIN] User IDs: $userIds');
    debugPrint('📝 [ADMIN] Title: $title');
    debugPrint('💬 [ADMIN] Message: $message');
    debugPrint('🏷️ [ADMIN] Type: $type');
    debugPrint('⚡ [ADMIN] Priority: ${priority ?? type.defaultPriority}');
    
    final batch = _firestore.batch();
    final timestamp = DateTime.now();
    final notificationId = timestamp.millisecondsSinceEpoch.toString();
    
    debugPrint('🆔 [ADMIN] Generated notification ID: $notificationId');
    
    int successCount = 0;
    int failureCount = 0;
    final List<String> errors = [];

    final notification = NotificationModel(
      id: notificationId,
      title: title,
      message: message,
      timestamp: timestamp,
      type: type,
      priority: priority ?? type.defaultPriority,
      actionUrl: actionUrl,
      expiryDate: expiryDate,
      senderId: senderId,
      senderName: senderName,
      targetType: targetType ?? NotificationTarget.custom,
      targetIds: userIds,
      metadata: metadata,
    );

    final notificationData = notification.toFirestore();

    try {
      debugPrint('📦 [ADMIN] Starting batch write for ${userIds.length} users');
      // Use batch write for efficiency (max 500 per batch)
      for (int i = 0; i < userIds.length; i++) {
        try {
          final userId = userIds[i];
          final docRef = _firestore
              .collection('notifications')
              .doc(userId)
              .collection('items')
              .doc();

          batch.set(docRef, notificationData);
          successCount++;
          
          if (i % 100 == 0) {
            debugPrint('📝 [ADMIN] Processed ${i + 1}/${userIds.length} users');
          }

          // Commit batch every 500 operations
          if ((i + 1) % 500 == 0) {
            debugPrint('💾 [ADMIN] Committing batch at ${i + 1} users');
            await batch.commit();
          }
        } catch (e) {
          failureCount++;
          errors.add('User ${userIds[i]}: $e');
          debugPrint('❌ [ADMIN] Failed to add user ${userIds[i]} to batch: $e');
        }
      }

      // Commit remaining operations
      if (successCount % 500 != 0) {
        debugPrint('💾 [ADMIN] Committing final batch');
        await batch.commit();
      }
      
      debugPrint('✅ [ADMIN] Batch write completed. Success: $successCount, Failures: $failureCount');

      // Log bulk send to admin collection
      await _logBulkNotification(
        notificationId: notificationId,
        title: title,
        type: type,
        priority: priority ?? type.defaultPriority,
        targetCount: userIds.length,
        successCount: successCount,
        failureCount: failureCount,
        senderId: senderId,
        targetType: targetType,
      );

      return {
        'success': true,
        'notificationId': notificationId,
        'totalTargets': userIds.length,
        'successCount': successCount,
        'failureCount': failureCount,
        'errors': errors,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'successCount': successCount,
        'failureCount': failureCount,
      };
    }
  }

  /// Schedule a notification for future delivery
  Future<String> scheduleNotification({
    required DateTime scheduledTime,
    required List<String> userIds,
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority? priority,
    String? actionUrl,
    DateTime? expiryDate,
    String? senderId,
    String? senderName,
    Map<String, dynamic>? metadata,
    NotificationTarget? targetType,
  }) async {
    final scheduleId = DateTime.now().millisecondsSinceEpoch.toString();

    await _firestore.collection('scheduled_notifications').doc(scheduleId).set({
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'userIds': userIds,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': (priority ?? type.defaultPriority).name,
      'actionUrl': actionUrl,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
      'senderId': senderId,
      'senderName': senderName,
      'metadata': metadata,
      'targetType': targetType?.name,
      'status': 'scheduled',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return scheduleId;
  }

  /// Log bulk notification for analytics
  Future<void> _logBulkNotification({
    required String notificationId,
    required String title,
    required NotificationType type,
    required NotificationPriority priority,
    required int targetCount,
    required int successCount,
    required int failureCount,
    String? senderId,
    NotificationTarget? targetType,
  }) async {
    await _firestore.collection('notification_logs').doc(notificationId).set({
      'notificationId': notificationId,
      'title': title,
      'type': type.name,
      'priority': priority.name,
      'targetType': targetType?.name,
      'targetCount': targetCount,
      'successCount': successCount,
      'failureCount': failureCount,
      'senderId': senderId,
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get notification statistics
  Future<Map<String, dynamic>> getNotificationStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore.collection('notification_logs');

    if (startDate != null) {
      query = query.where('sentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('sentAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();

    int totalSent = 0;
    int totalSuccess = 0;
    int totalFailures = 0;
    final Map<String, int> typeCount = {};
    final Map<String, int> priorityCount = {};

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalSent += (data['targetCount'] as int?) ?? 0;
      totalSuccess += (data['successCount'] as int?) ?? 0;
      totalFailures += (data['failureCount'] as int?) ?? 0;

      final type = data['type'] as String?;
      if (type != null) {
        typeCount[type] = (typeCount[type] ?? 0) + 1;
      }

      final priority = data['priority'] as String?;
      if (priority != null) {
        priorityCount[priority] = (priorityCount[priority] ?? 0) + 1;
      }
    }

    return {
      'totalNotifications': snapshot.docs.length,
      'totalSent': totalSent,
      'totalSuccess': totalSuccess,
      'totalFailures': totalFailures,
      'successRate': totalSent > 0 ? (totalSuccess / totalSent * 100).toStringAsFixed(2) : '0',
      'byType': typeCount,
      'byPriority': priorityCount,
    };
  }

  /// Delete expired notifications across all users
  Future<int> cleanupExpiredNotifications() async {
    final now = Timestamp.now();
    int deletedCount = 0;

    // This is an expensive operation - should be run as a background job
    final usersSnapshot = await _firestore.collection('notifications').get();

    for (final userDoc in usersSnapshot.docs) {
      final expiredSnapshot = await userDoc.reference
          .collection('items')
          .where('expiryDate', isLessThan: now)
          .get();

      for (final doc in expiredSnapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }
    }

    return deletedCount;
  }
  
  /// Log notification send event for analytics
  Future<void> _logNotificationSent({
    required String notificationId,
    required String targetType,
    required int targetCount,
    required int successCount,
    required int failureCount,
    required String type,
    required String priority,
    String? error,
  }) async {
    try {
      debugPrint('📈 [ADMIN] Logging notification send event');
      debugPrint('🎯 [ADMIN] Target Type: $targetType, Count: $targetCount');
      debugPrint('✅ [ADMIN] Success: $successCount, ❌ Failures: $failureCount');
      
      await _firestore.collection('notification_logs').add({
        'notificationId': notificationId,
        'sentAt': FieldValue.serverTimestamp(),
        'targetType': targetType,
        'targetCount': targetCount,
        'successCount': successCount,
        'failureCount': failureCount,
        'type': type,
        'priority': priority,
        'error': error,
      });
      
      debugPrint('📈 [ADMIN] Successfully logged notification event');
    } catch (e) {
      debugPrint('⚠️ [ADMIN] Failed to log notification: $e');
      // Don't rethrow - logging failures shouldn't break notification sending
    }
  }
  
  /// Create test students in Firestore for notification testing
  Future<void> createTestStudents() async {
    debugPrint('🧪 [ADMIN] Creating test students in Firestore');
    
    final testStudents = [
      {
        'student_id': 'TEST001',
        'name': 'John Doe',
        'email': 'john.doe@test.com',
        'major': 'Computer Science',
        'year': 2,
        'classId': 'CS-2024'
      },
      {
        'student_id': 'TEST002', 
        'name': 'Jane Smith',
        'email': 'jane.smith@test.com',
        'major': 'Computer Science',
        'year': 2,
        'classId': 'CS-2024'
      },
      {
        'student_id': 'TEST003',
        'name': 'Ali Hassan',
        'email': 'ali.hassan@test.com', 
        'major': 'Engineering',
        'year': 3,
        'classId': 'ENG-2023'
      },
      {
        'student_id': 'TEST004',
        'name': 'Sara Ahmed',
        'email': 'sara.ahmed@test.com',
        'major': 'Business',
        'year': 1, 
        'classId': 'BUS-2025'
      },
      {
        'student_id': 'TEST005',
        'name': 'Omar Khalil',
        'email': 'omar.khalil@test.com',
        'major': 'Computer Science',
        'year': 4,
        'classId': 'CS-2022'
      }
    ];
    
    final batch = _firestore.batch();
    
    for (final student in testStudents) {
      final docRef = _firestore.collection('students').doc(student['student_id'] as String);
      batch.set(docRef, student);
    }
    
    await batch.commit();
    
    debugPrint('✅ [ADMIN] Created ${testStudents.length} test students');
    debugPrint('👥 [ADMIN] Test students: ${testStudents.map((s) => s['name']).join(', ')}');
  }
}
