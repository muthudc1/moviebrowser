import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_browser/core/error/exceptions.dart';
import 'package:movie_browser/features/movies/data/models/movie_model.dart';
import 'package:movie_browser/features/movies/data/models/movie_response_model.dart';
import 'package:movie_browser/features/movies/data/repositories/movie_repository.dart';
import 'package:movie_browser/features/movies/presentation/providers/movie_list_provider.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;
  late MovieListProvider provider;

  final sampleMovies = [
    const Movie(
      id: 1,
      title: 'Inception',
      overview: 'A thief who steals corporate secrets...',
      voteAverage: 8.8,
      voteCount: 35000,
      releaseDate: '2010-07-16',
    ),
    const Movie(
      id: 2,
      title: 'Interstellar',
      overview: 'A team of explorers travel through a wormhole...',
      voteAverage: 8.7,
      voteCount: 32000,
      releaseDate: '2014-11-07',
    ),
  ];

  setUp(() {
    mockRepository = MockMovieRepository();
    provider = MovieListProvider(repository: mockRepository);
  });

  group('MovieListProvider Tests', () {
    test('initial state should have empty movies, page 1, and no errors', () {
      expect(provider.movies, isEmpty);
      expect(provider.currentPage, 1);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.currentCategory, MovieCategory.popular);
    });

    test('fetchMovies should update movies list and total pages on success', () async {
      when(() => mockRepository.getMoviesByCategory(MovieCategory.popular, page: 1))
          .thenAnswer((_) async => MovieResponse(
                page: 1,
                results: sampleMovies,
                totalPages: 5,
                totalResults: 10,
              ));

      await provider.fetchMovies();

      expect(provider.isLoading, false);
      expect(provider.movies.length, 2);
      expect(provider.movies.first.title, 'Inception');
      expect(provider.totalPages, 5);
      expect(provider.errorMessage, isNull);
    });

    test('fetchMovies should set errorMessage on network exception', () async {
      when(() => mockRepository.getMoviesByCategory(MovieCategory.popular, page: 1))
          .thenThrow(NetworkException('No internet connection'));

      await provider.fetchMovies();

      expect(provider.isLoading, false);
      expect(provider.movies, isEmpty);
      expect(provider.errorMessage, 'No internet connection');
    });

    test('loadMoreMovies should append new movies and advance current page', () async {
      when(() => mockRepository.getMoviesByCategory(MovieCategory.popular, page: 1))
          .thenAnswer((_) async => MovieResponse(
                page: 1,
                results: [sampleMovies[0]],
                totalPages: 2,
                totalResults: 2,
              ));

      when(() => mockRepository.getMoviesByCategory(MovieCategory.popular, page: 2))
          .thenAnswer((_) async => MovieResponse(
                page: 2,
                results: [sampleMovies[1]],
                totalPages: 2,
                totalResults: 2,
              ));

      await provider.fetchMovies();
      expect(provider.movies.length, 1);
      expect(provider.currentPage, 1);

      await provider.loadMoreMovies();
      expect(provider.movies.length, 2);
      expect(provider.currentPage, 2);
    });

    test('setCategory should reset page and fetch movies for new category', () async {
      when(() => mockRepository.getMoviesByCategory(MovieCategory.nowPlaying, page: 1))
          .thenAnswer((_) async => MovieResponse(
                page: 1,
                results: sampleMovies,
                totalPages: 3,
                totalResults: 6,
              ));

      provider.setCategory(MovieCategory.nowPlaying);

      expect(provider.currentCategory, MovieCategory.nowPlaying);
    });
  });
}
