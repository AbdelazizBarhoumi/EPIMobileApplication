// filepath: c:\Users\abdulazeezbrhomi\OneDrive\University\Epi\Sem3\flutter\epiApp\lib\features\profile\data\repositories\profile_repository.dart
import '../../../../core/api_client.dart';
import '../../../../core/models/student.dart';

class ProfileRepository {
  final ApiClient apiClient;

  ProfileRepository(this.apiClient);

  Future<Student> getProfile() async {
    final data = await apiClient.get('/api/students/profile');
    return Student.fromJson(data);
  }

  Future<Student> updateProfile(Map<String, dynamic> updates) async {
    final data = await apiClient.put('/api/students/profile', updates);
    return Student.fromJson(data);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await apiClient.put('/api/students/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
