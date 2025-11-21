// ============================================================================
// NEWS ITEM MODEL - Represents a news/announcement item
// ============================================================================

class NewsItem {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime publishDate;
  final String category;
  final String? link;
  final String? content;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.publishDate,
    required this.category,
    this.link,
    this.content,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      publishDate: DateTime.parse(json['publish_date'] as String),
      category: json['category'] as String,
      link: json['link'] as String?,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'publish_date': publishDate.toIso8601String(),
      'category': category,
      'link': link,
      'content': content,
    };
  }
}



