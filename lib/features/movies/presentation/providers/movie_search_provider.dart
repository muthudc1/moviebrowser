import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/debounce.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';

class MovieSearchProvider extends ChangeNotifier {
  final MovieRepository _repository;
  final Debounce _debouncer = Debounce(duration: const Duration(milliseconds: 450));

  MovieSearchProvider({required MovieRepository repository}) : _repository = repository;

  String _query = '';
  List<Movie> _results = [];
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalResults = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  bool _isSearching = false;

  // Getters
  String get query => _query;
  List<Movie> get results => _results;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalResults => _totalResults;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get isSearching => _isSearching;
  bool get hasMore => _currentPage < _totalPages && !_isLoadingMore;
  bool get hasNoResults => !_isLoading && _isSearching && _query.isNotEmpty && _results.isEmpty && _errorMessage == null;

  void onQueryChanged(String newQuery) {
    _query = newQuery;
    if (newQuery.trim().isEmpty) {
      clearSearch();
      return;
    }

    _isSearching = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _debouncer.run(() {
      _executeSearch(newQuery.trim(), page: 1);
    });
  }

  Future<void> _executeSearch(String query, {int page = 1}) async {
    _currentPage = page;
    try {
      final response = await _repository.searchMovies(query, page: page);
      if (page == 1) {
        _results = response.results;
      } else {
        final existingIds = _results.map((m) => m.id).toSet();
        final newItems = response.results.where((m) => !existingIds.contains(m.id)).toList();
        _results = [..._results, ...newItems];
      }
      _totalPages = response.totalPages;
      _totalResults = response.totalResults;
      _errorMessage = null;
    } on AppException catch (e) {
      if (_results.isEmpty) {
        _errorMessage = e.message;
      }
    } catch (e) {
      if (_results.isEmpty) {
        _errorMessage = 'Failed to search movies. Please try again.';
      }
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMore || _query.trim().isEmpty) return;

    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();

    try {
      final response = await _repository.searchMovies(_query.trim(), page: _currentPage);
      final existingIds = _results.map((m) => m.id).toSet();
      final newItems = response.results.where((m) => !existingIds.contains(m.id)).toList();
      _results = [..._results, ...newItems];
      _totalPages = response.totalPages;
    } catch (e) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _query = '';
    _results = [];
    _currentPage = 1;
    _totalPages = 0;
    _totalResults = 0;
    _isLoading = false;
    _isLoadingMore = false;
    _errorMessage = null;
    _isSearching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
