// lib/core/services/database/local_database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../../features/chat/data/models/message_model.dart';
import '../../../features/chat/data/models/conversation_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'epi_chat.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversationId TEXT NOT NULL,
        senderId TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        read INTEGER NOT NULL DEFAULT 0,
        type TEXT NOT NULL DEFAULT 'text',
        fileUrl TEXT,
        fileName TEXT,
        synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (conversationId) REFERENCES conversations (id)
      )
    ''');

    // Conversations table
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        participantIds TEXT NOT NULL,
        professorName TEXT NOT NULL,
        professorCourse TEXT NOT NULL,
        professorAvatar TEXT,
        professorBuilding TEXT,
        lastMessageText TEXT,
        lastMessageTimestamp INTEGER,
        lastMessageSenderId TEXT,
        unreadCount INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active',
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Pending messages table (for offline sending)
    await db.execute('''
      CREATE TABLE pending_messages (
        id TEXT PRIMARY KEY,
        conversationId TEXT NOT NULL,
        senderId TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        type TEXT NOT NULL DEFAULT 'text',
        fileUrl TEXT,
        fileName TEXT,
        retryCount INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_messages_conversation ON messages(conversationId)');
    await db.execute('CREATE INDEX idx_messages_timestamp ON messages(timestamp)');
    await db.execute('CREATE INDEX idx_conversations_timestamp ON conversations(lastMessageTimestamp)');

    debugPrint('✅ Local database created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
    debugPrint('🔄 Upgrading database from v$oldVersion to v$newVersion');
  }

  // ==================== MESSAGES ====================

  /// Save message to local database
  Future<void> saveMessage(String conversationId, MessageModel message, {bool synced = true}) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'id': message.id,
        'conversationId': conversationId,
        'senderId': message.senderId,
        'content': message.content,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
        'read': message.read ? 1 : 0,
        'type': message.type.name,
        'fileUrl': message.fileUrl,
        'fileName': message.fileName,
        'synced': synced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get messages for a conversation from local database
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => MessageModel(
      id: map['id'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      read: (map['read'] as int) == 1,
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      fileUrl: map['fileUrl'] as String?,
      fileName: map['fileName'] as String?,
    )).toList();
  }

  /// Delete messages for a conversation
  Future<void> deleteMessages(String conversationId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
    );
  }

  /// Get unsynced messages
  Future<List<Map<String, dynamic>>> getUnsyncedMessages() async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  /// Mark message as synced
  Future<void> markMessageSynced(String messageId) async {
    final db = await database;
    await db.update(
      'messages',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  // ==================== CONVERSATIONS ====================

  /// Save conversation to local database
  Future<void> saveConversation(ConversationModel conversation, {bool synced = true}) async {
    final db = await database;
    await db.insert(
      'conversations',
      {
        'id': conversation.id,
        'participantIds': conversation.participantIds.join(','),
        'professorName': conversation.professorInfo.name,
        'professorCourse': conversation.professorInfo.course,
        'professorAvatar': conversation.professorInfo.avatar,
        'professorBuilding': conversation.professorInfo.building,
        'lastMessageText': conversation.lastMessage?.text,
        'lastMessageTimestamp': conversation.lastMessage?.timestamp.millisecondsSinceEpoch,
        'lastMessageSenderId': conversation.lastMessage?.senderId,
        'unreadCount': conversation.unreadCount,
        'status': conversation.status,
        'synced': synced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all conversations from local database
  Future<List<ConversationModel>> getConversations() async {
    final db = await database;
    final maps = await db.query(
      'conversations',
      orderBy: 'lastMessageTimestamp DESC',
    );

    return maps.map((map) {
      final lastMessage = map['lastMessageText'] != null
          ? LastMessage(
              text: map['lastMessageText'] as String,
              timestamp: DateTime.fromMillisecondsSinceEpoch(map['lastMessageTimestamp'] as int),
              senderId: map['lastMessageSenderId'] as String,
            )
          : null;

      return ConversationModel(
        id: map['id'] as String,
        participantIds: (map['participantIds'] as String).split(','),
        professorInfo: ProfessorInfo(
          id: map['professorId'] as String? ?? '',
          name: map['professorName'] as String,
          course: map['professorCourse'] as String,
          avatar: map['professorAvatar'] as String? ?? '',
          building: map['professorBuilding'] as String? ?? '',
        ),
        lastMessage: lastMessage,
        unreadCount: map['unreadCount'] as int,
        status: map['status'] as String,
      );
    }).toList();
  }

  // ==================== PENDING MESSAGES ====================

  /// Add message to pending queue (for offline sending)
  Future<void> addPendingMessage(MessageModel message, String conversationId) async {
    final db = await database;
    await db.insert(
      'pending_messages',
      {
        'id': message.id,
        'conversationId': conversationId,
        'senderId': message.senderId,
        'content': message.content,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
        'type': message.type.name,
        'fileUrl': message.fileUrl,
        'fileName': message.fileName,
        'retryCount': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all pending messages
  Future<List<Map<String, dynamic>>> getPendingMessages() async {
    final db = await database;
    return await db.query('pending_messages', orderBy: 'timestamp ASC');
  }

  /// Delete pending message after successful send
  Future<void> deletePendingMessage(String messageId) async {
    final db = await database;
    await db.delete(
      'pending_messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// Increment retry count for pending message
  Future<void> incrementPendingMessageRetry(String messageId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE pending_messages SET retryCount = retryCount + 1 WHERE id = ?',
      [messageId],
    );
  }

  // ==================== CLEANUP ====================

  /// Clear all local data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('conversations');
    await db.delete('pending_messages');
    debugPrint('✅ Local database cleared');
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
