import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_response_model.dart';

abstract class MovieRemoteDataSource {
  Future<MovieResponse> getPopularMovies({int page = 1});
  Future<MovieResponse> getNowPlayingMovies({int page = 1});
  Future<MovieResponse> getTopRatedMovies({int page = 1});
  Future<MovieResponse> searchMovies(String query, {int page = 1});
  Future<MovieDetail> getMovieDetails(int movieId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final ApiClient apiClient;

  MovieRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MovieResponse> getPopularMovies({int page = 1}) async {
    final response = await apiClient.get(
      ApiConstants.popularMoviesEndpoint,
      queryParams: {'page': page.toString()},
    );
    return MovieResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<MovieResponse> getNowPlayingMovies({int page = 1}) async {
    final response = await apiClient.get(
      ApiConstants.nowPlayingMoviesEndpoint,
      queryParams: {'page': page.toString()},
    );
    return MovieResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<MovieResponse> getTopRatedMovies({int page = 1}) async {
    final response = await apiClient.get(
      ApiConstants.topRatedMoviesEndpoint,
      queryParams: {'page': page.toString()},
    );
    return MovieResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<MovieResponse> searchMovies(String query, {int page = 1}) async {
    final response = await apiClient.get(
      ApiConstants.searchMovieEndpoint,
      queryParams: {
        'query': query,
        'page': page.toString(),
      },
    );
    return MovieResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<MovieDetail> getMovieDetails(int movieId) async {
    final response = await apiClient.get(
      '${ApiConstants.movieDetailsEndpoint}/$movieId',
    );
    return MovieDetail.fromJson(response as Map<String, dynamic>);
  }
}
