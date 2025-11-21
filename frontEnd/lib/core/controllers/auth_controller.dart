import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../storage.dart';

enum AuthError {
  network,
  invalidCredentials,
  userExists,
  weakPassword,
  unknown,
}

class AuthController extends ChangeNotifier {
  final AuthService authService;
  bool loading = false;
  AuthError? lastError;
  String? errorMessage;

  AuthController(this.authService);

  Future<bool> login(String email, String password) async {
    print('\n🔐 ===== LOGIN ATTEMPT =====');
    print('📧 Email: $email');
    loading = true;
    lastError = null;
    errorMessage = null;
    notifyListeners();

    try {
      print('🔐 AuthController: Calling authService.login()...');
      final data = await authService.login(email, password);
      print('🔐 AuthController: Login response received');
      print('🔐 Token: ${data['token']?.substring(0, 20)}...');
      
      print('🔐 AuthController: Saving token to storage...');
      await Storage.saveToken(data['token']);
      print('🔐 ✅ Token saved successfully!');
      
      loading = false;
      notifyListeners();
      print('🔐 ===== LOGIN SUCCESS =====\n');
      return true;
    } catch (e) {
      print('🔐 ❌ LOGIN FAILED: $e');
      loading = false;
      _handleError(e);
      notifyListeners();
      print('🔐 ===== LOGIN FAILED =====\n');
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required int majorId,
    required int yearLevel,
    required String academicYear,
    required String classLevel,
  }) async {
    loading = true;
    lastError = null;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        majorId: majorId,
        yearLevel: yearLevel,
        academicYear: academicYear,
        classLevel: classLevel,
      );
      await Storage.saveToken(data['token']);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      loading = false;
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authService.logout();
    await Storage.deleteToken();
    notifyListeners();
  }

  void _handleError(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('Network error')) {
      lastError = AuthError.network;
      errorMessage = 'Network connection failed. Please check your internet.';
    } else if (errorStr.contains('Unauthorized')) {
      lastError = AuthError.invalidCredentials;
      errorMessage = 'Invalid email or password.';
    } else if (errorStr.contains('User already exists')) {
      lastError = AuthError.userExists;
      errorMessage = 'An account with this email already exists.';
    } else if (errorStr.contains('Password')) {
      lastError = AuthError.weakPassword;
      errorMessage = 'Password does not meet requirements.';
    } else {
      lastError = AuthError.unknown;
      errorMessage = 'An unexpected error occurred. Please try again.';
    }
  }

  void clearError() {
    lastError = null;
    errorMessage = null;
    notifyListeners();
  }
}
