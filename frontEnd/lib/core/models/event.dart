// ============================================================================
// EVENT MODEL - Represents events and activities
// ============================================================================

class Event {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? location;
  final String? imageUrl;
  final String category;
  final int? maxParticipants;
  final int? currentParticipants;
  final bool isRegistered;
  final String status;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    this.location,
    this.imageUrl,
    required this.category,
    this.maxParticipants,
    this.currentParticipants,
    required this.isRegistered,
    required this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      print('🎉 Event.fromJson: Parsing event ${json['id']}...');
      print('🎉   title: ${json['title']}');
      print('🎉   event_date: ${json['event_date']}');
      print('🎉   event_end_date: ${json['event_end_date']}');
      print('🎉   location: ${json['location']} (${json['location'].runtimeType})');
      print('🎉   is_registered: ${json['is_registered']} (${json['is_registered'].runtimeType})');
      print('🎉   is_active: ${json['is_active']} (${json['is_active'].runtimeType})');
      
      return Event(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        startDate: DateTime.parse(json['event_date'] as String),
        endDate: json['event_end_date'] != null ? DateTime.parse(json['event_end_date'] as String) : null,
        location: json['location'] as String?,
        imageUrl: json['image_url'] as String?,
        category: json['category'] as String,
        maxParticipants: json['capacity'] as int?,
        currentParticipants: json['registered_count'] as int?,
        isRegistered: json['is_registered'] as bool? ?? false,
        status: json['is_active'] == true ? 'active' : 'inactive',
      );
    } catch (e) {
      print('🎉 Event.fromJson ERROR: $e');
      print('🎉   JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': location,
      'image_url': imageUrl,
      'category': category,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'is_registered': isRegistered,
      'status': status,
    };
  }

  bool get isFull => maxParticipants != null && currentParticipants != null && currentParticipants! >= maxParticipants!;
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing => DateTime.now().isAfter(startDate) && (endDate == null || DateTime.now().isBefore(endDate!));
}
