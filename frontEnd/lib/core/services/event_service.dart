// ============================================================================
// EVENT SERVICE - Handles event related API calls
// ============================================================================

import '../api_client.dart';
import '../models/event.dart';

class EventService {
  final ApiClient apiClient;

  EventService(this.apiClient);

  /// Get all events
  Future<List<Event>> getAllEvents() async {
    print('🎉 EventService: Fetching events from API...');
    try {
      final response = await apiClient.get('/api/events');
      print('🎉 EventService: Response received');
      print('🎉 EventService: Response type: ${response['data'].runtimeType}');
      
      // Handle paginated response
      var eventsData = response['data'];
      if (eventsData is Map && eventsData.containsKey('data')) {
        print('🎉 EventService: Paginated response detected');
        eventsData = eventsData['data'];
      }
      
      final events = eventsData as List;
      print('🎉 EventService: Parsing ${events.length} events...');
      final eventList = events.map((event) {
        print('🎉   Parsing event: ${event['title']}');
        return Event.fromJson(event as Map<String, dynamic>);
      }).toList();
      print('🎉 EventService: Events parsed successfully');
      return eventList;
    } catch (e) {
      print('🎉 EventService: ERROR: $e');
      throw Exception('Failed to load events: $e');
    }
  }

  /// Get events that the student is registered for
  Future<List<Event>> getMyEvents() async {
    try {
      final response = await apiClient.get('/api/events/my-events');
      final events = response['data'] as List;
      return events.map((event) => Event.fromJson(event as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load my events: $e');
    }
  }

  /// Get event details by ID
  Future<Event> getEventById(int id) async {
    try {
      final response = await apiClient.get('/api/events/$id');
      return Event.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load event details: $e');
    }
  }

  /// Register for an event
  Future<void> registerForEvent(int eventId) async {
    try {
      await apiClient.post('/api/events/$eventId/register', {});
    } catch (e) {
      throw Exception('Failed to register for event: $e');
    }
  }

  /// Cancel event registration
  Future<void> cancelRegistration(int eventId) async {
    try {
      await apiClient.delete('/api/events/$eventId/register');
    } catch (e) {
      throw Exception('Failed to cancel registration: $e');
    }
  }
}
