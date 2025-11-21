// ============================================================================
// NEWS SERVICE - Handles news and announcements API calls
// ============================================================================

import '../api_client.dart';
import '../models/news_item.dart';

class NewsService {
  final ApiClient apiClient;

  NewsService(this.apiClient);

  /// Get all news items
  Future<List<NewsItem>> getAllNews() async {
    try {
      final response = await apiClient.get('/api/news');
      final news = response['data'] as List;
      return news.map((item) => NewsItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  /// Get featured news
  Future<List<NewsItem>> getFeaturedNews() async {
    try {
      final response = await apiClient.get('/api/news/featured');
      final news = response['data'] as List;
      return news.map((item) => NewsItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load featured news: $e');
    }
  }

  /// Get recent news
  Future<List<NewsItem>> getRecentNews() async {
    try {
      final response = await apiClient.get('/api/news/recent');
      final news = response['data'] as List;
      return news.map((item) => NewsItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load recent news: $e');
    }
  }

  /// Get news details by ID
  Future<NewsItem> getNewsById(int id) async {
    try {
      final response = await apiClient.get('/api/news/$id');
      return NewsItem.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load news details: $e');
    }
  }
}
