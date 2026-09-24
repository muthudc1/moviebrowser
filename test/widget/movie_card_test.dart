import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/features/movies/data/models/movie_model.dart';
import 'package:movie_browser/features/movies/presentation/widgets/movie_card.dart';

void main() {
  testWidgets('MovieCard renders movie title, release year, rating badge and triggers onTap', (WidgetTester tester) async {
    bool tapped = false;
    const movie = Movie(
      id: 999,
      title: 'Inception',
      overview: 'Dream within a dream',
      voteAverage: 8.8,
      voteCount: 30000,
      releaseDate: '2010-07-16',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: MovieCard(
              movie: movie,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('2010'), findsOneWidget);
    expect(find.text('8.8'), findsOneWidget);

    await tester.tap(find.byType(MovieCard));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
