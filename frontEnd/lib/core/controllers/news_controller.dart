// ============================================================================
// NEWS CONTROLLER - Manages news state
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/news_item.dart';
import '../services/news_service.dart';

enum NewsLoadingState { initial, loading, loaded, error }

class NewsController extends ChangeNotifier {
  final NewsService _newsService;

  NewsController(this._newsService);

  NewsLoadingState _state = NewsLoadingState.initial;
  List<NewsItem> _news = [];
  List<NewsItem> _featuredNews = [];
  NewsItem? _selectedNews;
  String? _errorMessage;

  NewsLoadingState get state => _state;
  List<NewsItem> get news => _news;
  List<NewsItem> get featuredNews => _featuredNews;
  NewsItem? get selectedNews => _selectedNews;
  String? get errorMessage => _errorMessage;

  /// Load all news
  Future<void> loadNews() async {
    _state = NewsLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _news = await _newsService.getAllNews();
      _state = NewsLoadingState.loaded;
    } catch (e) {
      _state = NewsLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Load featured news
  Future<void> loadFeaturedNews() async {
    try {
      _featuredNews = await _newsService.getFeaturedNews();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Load news details
  Future<void> loadNewsDetails(int newsId) async {
    try {
      _selectedNews = await _newsService.getNewsById(newsId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
