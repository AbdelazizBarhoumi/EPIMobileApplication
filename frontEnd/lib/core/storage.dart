import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    print('💾 Storage: Saving token (${token.substring(0, 20)}...)');
    await _storage.write(key: 'token', value: token);
    print('💾 Storage: Token saved successfully');
  }

  static Future<String?> readToken() async {
    print('📖 Storage: Reading token...');
    final token = await _storage.read(key: 'token');
    if (token != null) {
      print('📖 Storage: Token found (${token.substring(0, 20)}...)');
    } else {
      print('📖 Storage: No token found');
    }
    return token;
  }

  static Future<void> deleteToken() async {
    print('🗑️ Storage: Deleting token...');
    await _storage.delete(key: 'token');
    print('🗑️ Storage: Token deleted');
  }
}
