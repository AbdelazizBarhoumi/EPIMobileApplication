import '../api_client.dart';
import '../storage.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiClient.post('/api/login', {
        'email': email,
        'password': password
      });
      
      // Store token and student data
      if (response['token'] != null) {
        await Storage.saveToken(response['token'] as String);
      }
      
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required int majorId,
    required int yearLevel,
    required String academicYear,
    required String classLevel,
  }) async {
    try {
      final response = await apiClient.post('/api/register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'major_id': majorId,
        'year_level': yearLevel,
        'academic_year': academicYear,
        'class': classLevel,
      });
      
      // Store token and student data
      if (response['token'] != null) {
        await Storage.saveToken(response['token'] as String);
      }
      
      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      return await apiClient.post('/api/auth/refresh', {});
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.post('/api/logout', {});
      await Storage.deleteToken();
    } catch (e) {
      // Always delete token even if API call fails
      await Storage.deleteToken();
      throw Exception('Logout failed: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      return await apiClient.get('/api/user');
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }
}
