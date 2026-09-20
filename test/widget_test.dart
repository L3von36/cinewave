import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinewave/app.dart';
import 'package:cinewave/data/movie_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('boots from splash into the home catalog', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const CineWaveApp(),
      ),
    );

    // Splash shows the tagline while the catalog pre-warms.
    expect(find.text('RIDE THE STORY.'), findsOneWidget);

    // Cross past the splash timer and the simulated catalog fetch.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Home now renders its rails.
    expect(find.text('Trending Now'), findsOneWidget);
    expect(find.text('New & Noteworthy'), findsOneWidget);
  });
}
