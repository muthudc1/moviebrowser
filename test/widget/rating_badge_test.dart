import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/features/movies/presentation/widgets/rating_badge.dart';

void main() {
  testWidgets('RatingBadge displays star icon and formatted rating text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingBadge(rating: 8.433),
        ),
      ),
    );

    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.text('8.4'), findsOneWidget);
  });
}
