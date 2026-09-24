import '../../../../core/error/exceptions.dart';
import '../datasources/movie_local_datasource.dart';
import '../datasources/movie_remote_datasource.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_response_model.dart';

enum MovieCategory {
  popular('Popular', 'popular'),
  nowPlaying('Now Playing', 'now_playing'),
  topRated('Top Rated', 'top_rated');

  final String displayName;
  final String key;
  const MovieCategory(this.displayName, this.key);
}

abstract class MovieRepository {
  Future<MovieResponse> getMoviesByCategory(MovieCategory category, {int page = 1});
  Future<MovieResponse> searchMovies(String query, {int page = 1});
  Future<MovieDetail> getMovieDetails(int movieId);
}

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<MovieResponse> getMoviesByCategory(MovieCategory category, {int page = 1}) async {
    try {
      final MovieResponse response;
      switch (category) {
        case MovieCategory.popular:
          response = await remoteDataSource.getPopularMovies(page: page);
          break;
        case MovieCategory.nowPlaying:
          response = await remoteDataSource.getNowPlayingMovies(page: page);
          break;
        case MovieCategory.topRated:
          response = await remoteDataSource.getTopRatedMovies(page: page);
          break;
      }

      if (page == 1 && response.results.isNotEmpty) {
        await localDataSource.cacheMovies(category.key, response.results);
      }

      return response;
    } on NetworkException {
      if (page == 1) {
        final cached = await localDataSource.getCachedMovies(category.key);
        if (cached.isNotEmpty) {
          return MovieResponse(
            page: 1,
            results: cached,
            totalPages: 1,
            totalResults: cached.length,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<MovieResponse> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) {
      return const MovieResponse(page: 1, results: [], totalPages: 0, totalResults: 0);
    }
    return await remoteDataSource.searchMovies(query.trim(), page: page);
  }

  @override
  Future<MovieDetail> getMovieDetails(int movieId) async {
    try {
      final detail = await remoteDataSource.getMovieDetails(movieId);
      await localDataSource.cacheMovieDetail(movieId, detail);
      return detail;
    } on NetworkException {
      final cached = await localDataSource.getCachedMovieDetail(movieId);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }
}
