class ApiConstants {
  static const String defaultBaseUrl = 'https://api.themoviedb.org/3';
  static const String defaultImageBaseUrl = 'https://image.tmdb.org/t/p';

  // Endpoints
  static const String popularMoviesEndpoint = '/movie/popular';
  static const String nowPlayingMoviesEndpoint = '/movie/now_playing';
  static const String topRatedMoviesEndpoint = '/movie/top_rated';
  static const String movieDetailsEndpoint = '/movie';
  static const String searchMovieEndpoint = '/search/movie';

  // Image Sizes
  static const String posterSmall = 'w185';
  static const String posterMedium = 'w342';
  static const String posterLarge = 'w500';
  static const String backdropMedium = 'w780';
  static const String backdropLarge = 'w1280';
  static const String original = 'original';

  static String getPosterUrl(String? path, {String size = posterMedium}) {
    if (path == null || path.isEmpty) return '';
    return '$defaultImageBaseUrl/$size$path';
  }

  static String getBackdropUrl(String? path, {String size = backdropLarge}) {
    if (path == null || path.isEmpty) return '';
    return '$defaultImageBaseUrl/$size$path';
  }
}
