import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../data/movie_repository.dart';

class AppThemeState {
  final ThemeMode mode;
  final Color seed;

  const AppThemeState({
    this.mode = ThemeMode.dark,
    this.seed = kDefaultSeed,
  });
}

/// Theme mode + Material You seed color, both persisted.
class ThemeNotifier extends Notifier<AppThemeState> {
  static const _modeKey = 'theme_mode';
  static const _seedKey = 'theme_seed';

  @override
  AppThemeState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final modeIndex =
        prefs.getInt(_modeKey) ?? ThemeMode.dark.index;
    final mode = ThemeMode
        .values[modeIndex.clamp(0, ThemeMode.values.length - 1)];
    final seedValue = prefs.getInt(_seedKey) ?? kDefaultSeed.toARGB32();
    return AppThemeState(mode: mode, seed: Color(seedValue));
  }

  void setMode(ThemeMode mode) {
    state = AppThemeState(mode: mode, seed: state.seed);
    ref.read(sharedPreferencesProvider).setInt(_modeKey, mode.index);
  }

  void setSeed(Color seed) {
    state = AppThemeState(mode: state.mode, seed: seed);
    ref.read(sharedPreferencesProvider).setInt(_seedKey, seed.toARGB32());
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeState>(ThemeNotifier.new);
