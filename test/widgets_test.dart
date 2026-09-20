import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinewave/data/mock_data.dart';
import 'package:cinewave/widgets/common.dart';
import 'package:cinewave/widgets/poster_art.dart';

void main() {
  testWidgets('PosterArt paints procedural artwork with title overlay',
      (tester) async {
    final movie = kMovies.first;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: PosterArt(movie: movie),
          ),
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(PosterArt),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
    expect(find.text(movie.title), findsOneWidget);
  });

  testWidgets('RatingBadge renders one-decimal rating', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: RatingBadge(rating: 8.6)),
      ),
    );
    expect(find.text('8.6'), findsOneWidget);
  });

  testWidgets('FadeSlideIn reveals its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FadeSlideIn(child: Text('hello')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('hello'), findsOneWidget);
  });
}
