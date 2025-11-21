// ============================================================================
// CLUB MODEL - Represents student clubs and organizations
// ============================================================================

class Club {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final String category;
  final int memberCount;
  final bool isMember;
  final String? president;
  final String? contactEmail;

  Club({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.memberCount,
    required this.isMember,
    this.president,
    this.contactEmail,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String,
      memberCount: json['member_count'] as int,
      isMember: json['is_member'] as bool? ?? false,
      president: json['president'] as String?,
      contactEmail: json['contact_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'member_count': memberCount,
      'is_member': isMember,
      'president': president,
      'contact_email': contactEmail,
    };
  }
}
