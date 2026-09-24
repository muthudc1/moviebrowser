import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_model.dart';

abstract class MovieLocalDataSource {
  Future<void> cacheMovies(String cacheKey, List<Movie> movies);
  Future<List<Movie>> getCachedMovies(String cacheKey);
  Future<void> cacheMovieDetail(int id, MovieDetail detail);
  Future<MovieDetail?> getCachedMovieDetail(int id);
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  final SharedPreferences sharedPreferences;

  MovieLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheMovies(String cacheKey, List<Movie> movies) async {
    final jsonList = movies.map((m) => m.toJson()).toList();
    await sharedPreferences.setString('cached_movies_$cacheKey', jsonEncode(jsonList));
  }

  @override
  Future<List<Movie>> getCachedMovies(String cacheKey) async {
    final cachedString = sharedPreferences.getString('cached_movies_$cacheKey');
    if (cachedString != null && cachedString.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedString) as List<dynamic>;
        return decoded.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> cacheMovieDetail(int id, MovieDetail detail) async {
    await sharedPreferences.setString('cached_detail_$id', jsonEncode(detail.toJson()));
  }

  @override
  Future<MovieDetail?> getCachedMovieDetail(int id) async {
    final cachedString = sharedPreferences.getString('cached_detail_$id');
    if (cachedString != null && cachedString.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cachedString) as Map<String, dynamic>;
        return MovieDetail.fromJson(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
