// ============================================================================
// CLUB SERVICE - Handles club related API calls
// ============================================================================

import '../api_client.dart';
import '../models/club.dart';

class ClubService {
  final ApiClient apiClient;

  ClubService(this.apiClient);

  /// Get all clubs
  Future<List<Club>> getAllClubs() async {
    try {
      final response = await apiClient.get('/api/clubs');
      final clubs = response['data'] as List;
      return clubs.map((club) => Club.fromJson(club as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load clubs: $e');
    }
  }

  /// Get clubs that the student is a member of
  Future<List<Club>> getMyClubs() async {
    try {
      final response = await apiClient.get('/api/clubs/my-clubs');
      final clubs = response['data'] as List;
      return clubs.map((club) => Club.fromJson(club as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load my clubs: $e');
    }
  }

  /// Get club details by ID
  Future<Club> getClubById(int id) async {
    try {
      final response = await apiClient.get('/api/clubs/$id');
      return Club.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load club details: $e');
    }
  }

  /// Join a club
  Future<void> joinClub(int clubId) async {
    try {
      await apiClient.post('/api/clubs/$clubId/join', {});
    } catch (e) {
      throw Exception('Failed to join club: $e');
    }
  }

  /// Leave a club
  Future<void> leaveClub(int clubId) async {
    try {
      await apiClient.delete('/api/clubs/$clubId/leave');
    } catch (e) {
      throw Exception('Failed to leave club: $e');
    }
  }
}
