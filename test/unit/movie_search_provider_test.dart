import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_browser/features/movies/data/repositories/movie_repository.dart';
import 'package:movie_browser/features/movies/presentation/providers/movie_search_provider.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;
  late MovieSearchProvider provider;

  setUp(() {
    mockRepository = MockMovieRepository();
    provider = MovieSearchProvider(repository: mockRepository);
  });

  group('MovieSearchProvider Tests', () {
    test('initial state should be empty and not searching', () {
      expect(provider.query, '');
      expect(provider.results, isEmpty);
      expect(provider.isSearching, false);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('clearSearch should reset all search states', () {
      provider.onQueryChanged('Batman');
      provider.clearSearch();

      expect(provider.query, '');
      expect(provider.results, isEmpty);
      expect(provider.isSearching, false);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('onQueryChanged with empty string should reset search', () {
      provider.onQueryChanged('');

      expect(provider.query, '');
      expect(provider.results, isEmpty);
      expect(provider.isSearching, false);
    });
  });
}
