import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';
import '../data/models/movie.dart';

/// Overridden in main() with the real SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

class MovieRepository {
  const MovieRepository();

  /// Simulates a network fetch so skeleton shimmer states are visible.
  Future<List<Movie>> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return kMovies;
  }
}

final movieRepositoryProvider =
    Provider<MovieRepository>((_) => const MovieRepository());

final moviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(movieRepositoryProvider).load();
});

final movieByIdProvider = Provider.family<Movie?, String>((ref, id) {
  final movies = ref.watch(moviesProvider).value ?? const <Movie>[];
  for (final m in movies) {
    if (m.id == id) return m;
  }
  return null;
});

/// Titles that share the most genres with [id], best rated first.
final similarProvider = Provider.family<List<Movie>, String>((ref, id) {
  final me = ref.watch(movieByIdProvider(id));
  final movies = ref.watch(moviesProvider).value ?? const <Movie>[];
  if (me == null) return const <Movie>[];
  final others =
      movies.where((m) => m.id != id).toList()
        ..sort((a, b) {
          final sa = a.genres.where(me.genres.contains).length;
          final sb = b.genres.where(me.genres.contains).length;
          final cmp = sb.compareTo(sa);
          return cmp != 0 ? cmp : b.rating.compareTo(a.rating);
        });
  return others.take(6).toList();
});

/// Currently selected genre filter on the Explore tab (null = all).
final selectedGenreProvider = StateProvider<String?>((_) => null);

/// Current search text on the Explore tab.
final searchQueryProvider = StateProvider<String>((_) => '');
