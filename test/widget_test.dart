import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:movie_browser/features/movies/data/models/movie_model.dart';
import 'package:movie_browser/features/movies/data/models/movie_response_model.dart';
import 'package:movie_browser/features/movies/data/repositories/movie_repository.dart';
import 'package:movie_browser/features/movies/presentation/providers/movie_detail_provider.dart';
import 'package:movie_browser/features/movies/presentation/providers/movie_list_provider.dart';
import 'package:movie_browser/features/movies/presentation/providers/movie_search_provider.dart';
import 'package:movie_browser/features/movies/presentation/providers/theme_provider.dart';
import 'package:movie_browser/features/movies/presentation/screens/movie_list_screen.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;

  final sampleMovies = [
    const Movie(
      id: 1,
      title: 'Interstellar',
      overview: 'Wormhole expedition in search of a new home.',
      voteAverage: 8.7,
      voteCount: 33000,
      releaseDate: '2014-11-07',
    ),
  ];

  setUp(() {
    mockRepository = MockMovieRepository();
  });

  testWidgets('MovieListScreen renders app title and fetched movies list', (WidgetTester tester) async {
    when(() => mockRepository.getMoviesByCategory(MovieCategory.popular, page: 1))
        .thenAnswer((_) async => MovieResponse(
              page: 1,
              results: sampleMovies,
              totalPages: 1,
              totalResults: 1,
            ));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(null)),
          ChangeNotifierProvider(create: (_) => MovieListProvider(repository: mockRepository)),
          ChangeNotifierProvider(create: (_) => MovieSearchProvider(repository: mockRepository)),
          ChangeNotifierProvider(create: (_) => MovieDetailProvider(repository: mockRepository)),
        ],
        child: const MaterialApp(
          home: MovieListScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    // Pump frames to complete async fetch
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Movie Browser'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.text('Interstellar'), findsOneWidget);
  });
}
