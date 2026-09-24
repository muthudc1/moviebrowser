import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';

class MovieListProvider extends ChangeNotifier {
  final MovieRepository _repository;

  MovieListProvider({required MovieRepository repository}) : _repository = repository;

  MovieCategory _currentCategory = MovieCategory.popular;
  List<Movie> _movies = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  bool _isOfflineCache = false;

  // Getters
  MovieCategory get currentCategory => _currentCategory;
  List<Movie> get movies => _movies;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get isOfflineCache => _isOfflineCache;
  bool get hasMore => _currentPage < _totalPages && !_isLoadingMore;
  bool get isEmpty => !_isLoading && _movies.isEmpty && _errorMessage == null;

  Future<void> fetchMovies({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    if (_currentPage == 1) {
      _isLoading = true;
      _errorMessage = null;
      _isOfflineCache = false;
      notifyListeners();
    }

    try {
      final response = await _repository.getMoviesByCategory(
        _currentCategory,
        page: _currentPage,
      );

      if (_currentPage == 1) {
        _movies = response.results;
      } else {
        // Prevent duplicates
        final existingIds = _movies.map((m) => m.id).toSet();
        final newItems = response.results.where((m) => !existingIds.contains(m.id)).toList();
        _movies = [..._movies, ...newItems];
      }

      _totalPages = response.totalPages;
      _errorMessage = null;
    } on AppException catch (e) {
      if (_movies.isEmpty) {
        _errorMessage = e.message;
      }
    } catch (e) {
      if (_movies.isEmpty) {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      }
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMovies() async {
    if (_isLoading || _isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();

    try {
      final response = await _repository.getMoviesByCategory(
        _currentCategory,
        page: _currentPage,
      );

      final existingIds = _movies.map((m) => m.id).toSet();
      final newItems = response.results.where((m) => !existingIds.contains(m.id)).toList();
      _movies = [..._movies, ...newItems];
      _totalPages = response.totalPages;
      _errorMessage = null;
    } catch (e) {
      _currentPage--;
      debugPrint('Failed to load more movies: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setCategory(MovieCategory category) {
    if (_currentCategory == category) return;
    _currentCategory = category;
    _currentPage = 1;
    _movies = [];
    fetchMovies();
  }
}
