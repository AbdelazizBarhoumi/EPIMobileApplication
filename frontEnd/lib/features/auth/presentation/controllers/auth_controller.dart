// filepath: c:\Users\abdulazeezbrhomi\OneDrive\University\Epi\Sem3\flutter\epiApp\lib\features\auth\presentation\controllers\auth_controller.dart
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth_models.dart';
import '../../../../core/storage.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthController extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  AuthResponse? _authResponse;

  AuthController(this.authRepository) {
    _checkAuthStatus();
  }

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  AuthResponse? get authResponse => _authResponse;
  bool get isAuthenticated => _state == AuthState.authenticated;

  Future<void> _checkAuthStatus() async {
    final token = await Storage.readToken();
    if (token != null) {
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await authRepository.login(request);

      await Storage.saveToken(response.token);
      _authResponse = response;
      _state = AuthState.authenticated;

      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = _parseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = RegisterRequest(name: name, email: email, password: password);
      final response = await authRepository.register(request);

      await Storage.saveToken(response.token);
      _authResponse = response;
      _state = AuthState.authenticated;

      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = _parseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();
    } catch (_) {
      // Ignore logout errors
    }

    await Storage.deleteToken();
    _authResponse = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('Network error')) {
      return 'Network connection failed. Please check your internet.';
    } else if (error.contains('Unauthorized')) {
      return 'Invalid email or password.';
    } else if (error.contains('User already exists')) {
      return 'An account with this email already exists.';
    } else if (error.contains('Password')) {
      return 'Password does not meet requirements.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
