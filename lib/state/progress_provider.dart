import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../data/movie_repository.dart';

/// Persisted watch progress per title id (0..1).
///
/// First launch seeds a few entries so the "Continue Watching" rail is alive.
class ProgressNotifier extends Notifier<Map<String, double>> {
  static const _key = 'progress';

  @override
  Map<String, double> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    if (prefs.getBool(kProgressSeededKey) != true) {
      final raw = prefs.getString(_key);
      final existing = raw == null
          ? <String, double>{}
          : Map<String, double>.from(jsonDecode(raw) as Map<dynamic, dynamic>);
      existing.addAll(kInitialProgress);
      prefs.setString(_key, jsonEncode(existing));
      prefs.setBool(kProgressSeededKey, true);
      return existing;
    }
    final raw = prefs.getString(_key);
    if (raw == null) return const <String, double>{};
    return Map<String, double>.from(
        jsonDecode(raw) as Map<dynamic, dynamic>);
  }

  /// Records progress; entries >= 96% are considered finished and dropped
  /// from Continue Watching, entries <= 2% are ignored.
  void set(String id, double progress) {
    final next = <String, double>{...state};
    if (progress >= 0.96) {
      next.remove(id);
    } else if (progress > 0.02) {
      next[id] = progress;
    } else {
      next.remove(id);
    }
    state = next;
    ref.read(sharedPreferencesProvider).setString(_key, jsonEncode(next));
  }

  void clearAll() {
    state = const <String, double>{};
    ref.read(sharedPreferencesProvider).remove(_key);
  }
}

final progressProvider =
    NotifierProvider<ProgressNotifier, Map<String, double>>(
        ProgressNotifier.new);
