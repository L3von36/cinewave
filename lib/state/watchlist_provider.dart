import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/movie_repository.dart';

/// Persisted set of title ids saved by the user.
class WatchlistNotifier extends Notifier<Set<String>> {
  static const _key = 'watchlist';

  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  void toggle(String id) {
    final next = <String>{...state};
    if (!next.remove(id)) next.add(id);
    state = next;
    ref.read(sharedPreferencesProvider).setStringList(_key, next.toList());
  }

  bool contains(String id) => state.contains(id);
}

final watchlistProvider =
    NotifierProvider<WatchlistNotifier, Set<String>>(WatchlistNotifier.new);
