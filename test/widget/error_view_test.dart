import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/features/movies/presentation/widgets/error_view.dart';

void main() {
  testWidgets('ErrorView displays message and triggers retry callback on button tap', (WidgetTester tester) async {
    bool retryPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'Failed to reach TMDB servers.',
            onRetry: () {
              retryPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Failed to reach TMDB servers.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pump();

    expect(retryPressed, isTrue);
  });
}
