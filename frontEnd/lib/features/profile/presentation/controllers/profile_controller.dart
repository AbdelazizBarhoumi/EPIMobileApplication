// filepath: c:\Users\abdulazeezbrhomi\OneDrive\University\Epi\Sem3\flutter\epiApp\lib\features\profile\presentation\controllers\profile_controller.dart
import 'package:flutter/material.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/models/student.dart';

enum ProfileState {
  initial,
  loading,
  loaded,
  error,
}

class ProfileController extends ChangeNotifier {
  final ProfileRepository profileRepository;

  ProfileState _state = ProfileState.initial;
  Student? _student;
  String? _errorMessage;

  ProfileController(this.profileRepository);

  ProfileState get state => _state;
  Student? get student => _student;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    _state = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _student = await profileRepository.getProfile();
      _state = ProfileState.loaded;
    } catch (e) {
      _state = ProfileState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_student == null) return false;

    _state = ProfileState.loading;
    notifyListeners();

    try {
      _student = await profileRepository.updateProfile(updates);
      _state = ProfileState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ProfileState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _state = ProfileState.loading;
    notifyListeners();

    try {
      await profileRepository.changePassword(currentPassword, newPassword);
      _state = ProfileState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ProfileState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
