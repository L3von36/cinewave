import 'package:flutter_test/flutter_test.dart';

import 'package:cinewave/data/mock_data.dart';

void main() {
  group('demo catalog', () {
    test('has unique ids', () {
      final ids = kMovies.map((m) => m.id).toSet();
      expect(ids.length, kMovies.length);
    });

    test('every title has genres and a valid rating/year', () {
      for (final m in kMovies) {
        expect(m.genres, isNotEmpty, reason: '${m.id} has no genres');
        expect(m.rating, greaterThanOrEqualTo(0.0), reason: m.id);
        expect(m.rating, lessThanOrEqualTo(10.0), reason: m.id);
        expect(m.year, greaterThan(1990), reason: m.id);
        expect(m.synopsis, isNotEmpty, reason: m.id);
        expect(m.cast, isNotEmpty, reason: m.id);
      }
    });

    test('series have seasons with episodes', () {
      for (final m in kMovies.where((m) => m.isSeries)) {
        expect(m.seasons, isNotEmpty, reason: m.id);
        for (final s in m.seasons) {
          expect(s.episodes, isNotEmpty, reason: '${m.id} S${s.number}');
        }
      }
    });

    test('home rails only reference existing genres', () {
      final genres = <String>{for (final m in kMovies) ...m.genres};
      for (final g in kHomeGenres) {
        expect(genres.contains(g), isTrue, reason: g);
      }
    });

    test('continue-watching seeds reference real titles', () {
      final ids = kMovies.map((m) => m.id).toSet();
      for (final id in kInitialProgress.keys) {
        expect(ids.contains(id), isTrue, reason: id);
      }
    });
  });
}
