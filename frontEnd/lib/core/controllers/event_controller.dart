// ============================================================================
// EVENT CONTROLLER - Manages event state
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/event_service.dart';

enum EventLoadingState { initial, loading, loaded, error }

class EventController extends ChangeNotifier {
  final EventService _eventService;

  EventController(this._eventService);

  EventLoadingState _state = EventLoadingState.initial;
  List<Event> _events = [];
  List<Event> _myEvents = [];
  Event? _selectedEvent;
  String? _errorMessage;
  bool _isPerformingAction = false;

  EventLoadingState get state => _state;
  List<Event> get events => _events;
  List<Event> get myEvents => _myEvents;
  Event? get selectedEvent => _selectedEvent;
  String? get errorMessage => _errorMessage;
  bool get isPerformingAction => _isPerformingAction;

  /// Load all events
  Future<void> loadEvents() async {
    print('🎉 EventController: Loading events...');
    _state = EventLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _eventService.getAllEvents();
      print('🎉 EventController: Events loaded - Count: ${_events.length}');
      for (var event in _events.take(3)) {
        print('🎉   - ${event.title} (${event.startDate})');
      }
      _state = EventLoadingState.loaded;
    } catch (e) {
      print('🎉 EventController: ERROR loading events: $e');
      _state = EventLoadingState.error;
      _errorMessage = e.toString();
      rethrow;
    }
    notifyListeners();
  }

  /// Load my events
  Future<void> loadMyEvents() async {
    try {
      _myEvents = await _eventService.getMyEvents();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Load event details
  Future<void> loadEventDetails(int eventId) async {
    try {
      _selectedEvent = await _eventService.getEventById(eventId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Register for an event
  Future<bool> registerForEvent(int eventId) async {
    _isPerformingAction = true;
    notifyListeners();

    try {
      await _eventService.registerForEvent(eventId);
      await loadEvents(); // Refresh events
      await loadMyEvents(); // Refresh my events
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

  /// Cancel event registration
  Future<bool> cancelRegistration(int eventId) async {
    _isPerformingAction = true;
    notifyListeners();

    try {
      await _eventService.cancelRegistration(eventId);
      await loadEvents(); // Refresh events
      await loadMyEvents(); // Refresh my events
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

  List<Event> get upcomingEvents => _events.where((e) => e.isUpcoming).toList();
  List<Event> get ongoingEvents => _events.where((e) => e.isOngoing).toList();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
