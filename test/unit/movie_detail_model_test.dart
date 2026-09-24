import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/features/movies/data/models/movie_detail_model.dart';

void main() {
  group('MovieDetail Model Tests', () {
    final sampleJson = {
      'id': 550,
      'title': 'Fight Club',
      'overview': 'An unfulfilled insurance salesman...',
      'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      'backdrop_path': '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
      'vote_average': 8.433,
      'vote_count': 26000,
      'release_date': '1999-10-15',
      'runtime': 139,
      'genres': [
        {'id': 18, 'name': 'Drama'},
        {'id': 53, 'name': 'Thriller'},
      ],
      'tagline': 'Mischief. Mayhem. Soap.',
      'status': 'Released',
      'budget': 63000000,
      'revenue': 100853753,
    };

    test('should correctly deserialize full JSON into MovieDetail object', () {
      final detail = MovieDetail.fromJson(sampleJson);

      expect(detail.id, 550);
      expect(detail.title, 'Fight Club');
      expect(detail.runtime, 139);
      expect(detail.genres.length, 2);
      expect(detail.genres.first.name, 'Drama');
      expect(detail.tagline, 'Mischief. Mayhem. Soap.');
      expect(detail.status, 'Released');
      expect(detail.budget, 63000000);
      expect(detail.revenue, 100853753);
    });

    test('should format runtime, currency, and date correctly', () {
      final detail = MovieDetail.fromJson(sampleJson);

      expect(detail.formattedRuntime, '2h 19m');
      expect(detail.formattedReleaseDate, 'October 15, 1999');
      expect(detail.formattedBudget, '\$63,000,000');
      expect(detail.formattedRevenue, '\$100,853,753');
    });

    test('should handle missing optional fields safely', () {
      final minimalJson = <String, dynamic>{
        'id': 100,
      };

      final detail = MovieDetail.fromJson(minimalJson);

      expect(detail.id, 100);
      expect(detail.title, 'Untitled');
      expect(detail.runtime, isNull);
      expect(detail.formattedRuntime, 'N/A');
      expect(detail.genres, isEmpty);
      expect(detail.formattedBudget, 'N/A');
      expect(detail.formattedRevenue, 'N/A');
    });
  });
}
