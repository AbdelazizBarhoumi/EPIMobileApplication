// filepath: c:\Users\abdulazeezbrhomi\OneDrive\University\Epi\Sem3\flutter\epiApp\lib\features\auth\data\repositories\auth_repository.dart
import '../../../../core/api_client.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<AuthResponse> login(LoginRequest request) async {
    final data = await apiClient.post('/api/auth/login', request.toJson());
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final data = await apiClient.post('/api/auth/register', request.toJson());
    return AuthResponse.fromJson(data);
  }

  Future<void> logout() async {
    await apiClient.post('/api/auth/logout', {});
  }

  Future<AuthResponse> refreshToken() async {
    final data = await apiClient.post('/api/auth/refresh', {});
    return AuthResponse.fromJson(data);
  }
}
