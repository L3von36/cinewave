import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinewave/data/mock_data.dart';
import 'package:cinewave/data/movie_repository.dart';
import 'package:cinewave/state/progress_provider.dart';
import 'package:cinewave/state/theme_provider.dart';
import 'package:cinewave/state/watchlist_provider.dart';

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('watchlist toggles', () async {
    final c = await _container();
    expect(c.read(watchlistProvider), isEmpty);
    c.read(watchlistProvider.notifier).toggle('aurora-protocol');
    expect(c.read(watchlistProvider).contains('aurora-protocol'), isTrue);
    c.read(watchlistProvider.notifier).toggle('aurora-protocol');
    expect(c.read(watchlistProvider).contains('aurora-protocol'), isFalse);
  });

  test('watchlist survives container restart (persistence)', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c1 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    c1.read(watchlistProvider.notifier).toggle('nightsharp');
    c1.dispose();

    final c2 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    expect(c2.read(watchlistProvider), {'nightsharp'});
    c2.dispose();
  });

  test('progress seeds defaults once and drops finished titles', () async {
    final c = await _container();
    final progress = c.read(progressProvider);
    expect(progress['aurora-protocol'], closeTo(0.42, 0.0001));

    c.read(progressProvider.notifier).set('the-last-lighthouse', 0.5);
    expect(
      c.read(progressProvider)['the-last-lighthouse'],
      closeTo(0.5, 0.0001),
    );

    c.read(progressProvider.notifier).set('the-last-lighthouse', 0.99);
    expect(
      c.read(progressProvider).containsKey('the-last-lighthouse'),
      isFalse,
    );
  });

  test('theme defaults to dark violet and persists accent', () async {
    final c = await _container();
    expect(c.read(themeProvider).mode, ThemeMode.dark);
    c.read(themeProvider.notifier).setSeed(const Color(0xFF22D3EE));
    expect(c.read(themeProvider).seed, const Color(0xFF22D3EE));
  });

  test('movies provider loads the full catalog', () async {
    final c = await _container();
    final movies = await c.read(moviesProvider.future);
    expect(movies.length, kMovies.length);
  });
}
