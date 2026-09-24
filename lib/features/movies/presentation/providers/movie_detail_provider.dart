import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/models/movie_detail_model.dart';
import '../../data/repositories/movie_repository.dart';

class MovieDetailProvider extends ChangeNotifier {
  final MovieRepository _repository;

  MovieDetailProvider({required MovieRepository repository}) : _repository = repository;

  final Map<int, MovieDetail> _detailsCache = {};
  final Map<int, bool> _loadingStates = {};
  final Map<int, String?> _errorStates = {};

  MovieDetail? getDetail(int movieId) => _detailsCache[movieId];
  bool isLoading(int movieId) => _loadingStates[movieId] ?? false;
  String? getError(int movieId) => _errorStates[movieId];

  Future<void> fetchMovieDetail(int movieId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _detailsCache.containsKey(movieId)) {
      return;
    }

    _loadingStates[movieId] = true;
    _errorStates[movieId] = null;
    notifyListeners();

    try {
      final detail = await _repository.getMovieDetails(movieId);
      _detailsCache[movieId] = detail;
      _errorStates[movieId] = null;
    } on AppException catch (e) {
      _errorStates[movieId] = e.message;
    } catch (e) {
      _errorStates[movieId] = 'Failed to load movie details. Please try again.';
    } finally {
      _loadingStates[movieId] = false;
      notifyListeners();
    }
  }
}
