// ============================================================================
// CLUB CONTROLLER - Manages club state
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/club.dart';
import '../services/club_service.dart';

enum ClubLoadingState { initial, loading, loaded, error }

class ClubController extends ChangeNotifier {
  final ClubService _clubService;

  ClubController(this._clubService);

  ClubLoadingState _state = ClubLoadingState.initial;
  List<Club> _clubs = [];
  List<Club> _myClubs = [];
  Club? _selectedClub;
  String? _errorMessage;
  bool _isPerformingAction = false;

  ClubLoadingState get state => _state;
  List<Club> get clubs => _clubs;
  List<Club> get myClubs => _myClubs;
  Club? get selectedClub => _selectedClub;
  String? get errorMessage => _errorMessage;
  bool get isPerformingAction => _isPerformingAction;

  /// Load all clubs
  Future<void> loadClubs() async {
    _state = ClubLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _clubs = await _clubService.getAllClubs();
      _state = ClubLoadingState.loaded;
    } catch (e) {
      _state = ClubLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Load my clubs
  Future<void> loadMyClubs() async {
    try {
      _myClubs = await _clubService.getMyClubs();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Load club details
  Future<void> loadClubDetails(int clubId) async {
    try {
      _selectedClub = await _clubService.getClubById(clubId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Join a club
  Future<bool> joinClub(int clubId) async {
    _isPerformingAction = true;
    notifyListeners();

    try {
      await _clubService.joinClub(clubId);
      await loadClubs(); // Refresh clubs
      await loadMyClubs(); // Refresh my clubs
      _isPerformingAction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isPerformingAction = false;
      notifyListeners();
      return false;
    }
  }

  /// Leave a club
  Future<bool> leaveClub(int clubId) async {
    _isPerformingAction = true;
    notifyListeners();

    try {
      await _clubService.leaveClub(clubId);
      await loadClubs(); // Refresh clubs
      await loadMyClubs(); // Refresh my clubs
      _isPerformingAction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isPerformingAction = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
