import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/features/movies/data/models/movie_model.dart';

void main() {
  group('Movie Model Tests', () {
    final sampleJson = {
      'id': 550,
      'title': 'Fight Club',
      'overview': 'An unfulfilled insurance salesman...',
      'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      'backdrop_path': '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
      'vote_average': 8.433,
      'vote_count': 26000,
      'release_date': '1999-10-15',
      'genre_ids': [18, 53],
      'popularity': 61.416,
    };

    test('should correctly deserialize full JSON into Movie object', () {
      final movie = Movie.fromJson(sampleJson);

      expect(movie.id, 550);
      expect(movie.title, 'Fight Club');
      expect(movie.overview, 'An unfulfilled insurance salesman...');
      expect(movie.posterPath, '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg');
      expect(movie.backdropPath, '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg');
      expect(movie.voteAverage, 8.433);
      expect(movie.voteCount, 26000);
      expect(movie.releaseDate, '1999-10-15');
      expect(movie.genreIds, [18, 53]);
      expect(movie.popularity, 61.416);
    });

    test('should handle null/missing fields safely with default values', () {
      final minimalJson = <String, dynamic>{
        'id': 100,
      };

      final movie = Movie.fromJson(minimalJson);

      expect(movie.id, 100);
      expect(movie.title, 'Untitled');
      expect(movie.overview, '');
      expect(movie.posterPath, isNull);
      expect(movie.backdropPath, isNull);
      expect(movie.voteAverage, 0.0);
      expect(movie.voteCount, 0);
      expect(movie.releaseDate, '');
      expect(movie.genreIds, isEmpty);
      expect(movie.popularity, 0.0);
    });

    test('should compute helper getters accurately', () {
      final movie = Movie.fromJson(sampleJson);

      expect(movie.releaseYear, '1999');
      expect(movie.ratingFormatted, '8.4');
      expect(movie.posterUrl, contains('/w342/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg'));
      expect(movie.largePosterUrl, contains('/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg'));
      expect(movie.backdropUrl, contains('/w1280/hZkgoQYus5vegHoetLkCJzb17zJ.jpg'));
      expect(movie.formattedReleaseDate, 'October 15, 1999');
    });

    test('should correctly serialize Movie object back to JSON', () {
      final movie = Movie.fromJson(sampleJson);
      final json = movie.toJson();

      expect(json['id'], 550);
      expect(json['title'], 'Fight Club');
      expect(json['poster_path'], '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg');
      expect(json['vote_average'], 8.433);
    });
  });
}
