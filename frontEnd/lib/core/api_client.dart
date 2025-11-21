import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage.dart';

class ApiClient {
  final String baseUrl;
  final Duration timeout;

  ApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
  });

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    return _request('GET', path, queryParams: queryParams);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    return _request('POST', path, body: body);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    return _request('PUT', path, body: body);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _request('DELETE', path);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final token = await Storage.readToken();
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final requestBody = body != null ? jsonEncode(body) : null;

    // 🔍 LOG REQUEST
    print('\n🌐 ===== API REQUEST =====');
    print('📍 $method $uri');
    print('🔑 Token: ${token != null ? "${token.substring(0, 20)}..." : "NO TOKEN"}');
    print('📦 Body: ${body ?? "none"}');

    try {
      late http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(timeout);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: requestBody).timeout(timeout);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: requestBody).timeout(timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers).timeout(timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // 🔍 LOG RESPONSE
      print('📥 Response: ${response.statusCode}');
      print('📄 Body Preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      print('========================\n');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Network Error: $e');
      print('========================\n');
      throw Exception('Network error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    print('🔍 Handling response: ${response.statusCode}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        print('✅ Success response, parsing JSON...');
        final data = jsonDecode(response.body);
        print('✅ JSON parsed successfully');
        return data;
      } catch (e) {
        print('❌ Failed to parse JSON: $e');
        throw Exception('Invalid response format');
      }
    } else if (response.statusCode == 401 || response.statusCode == 302 || response.statusCode == 405) {
      // Handle authentication failures:
      // 401 = Unauthorized
      // 302 = Redirect to login (token invalid/expired)
      // 405 = Method Not Allowed on /login (means we were redirected to GET /login)
      print('🔐 AUTH FAILURE DETECTED: ${response.statusCode}');
      print('🔐 Deleting token and throwing Unauthorized exception');
      Storage.deleteToken();
      throw Exception('Unauthorized - please login again');
    } else {
      print('⚠️ Error response: ${response.statusCode}');
      print('⚠️ Response body: ${response.body}');
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Request failed: ${response.statusCode}');
      } catch (_) {
        throw Exception('Request failed: ${response.statusCode}');
      }
    }
  }
}
