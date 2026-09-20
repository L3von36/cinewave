import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'state/theme_provider.dart';

class CineWaveApp extends ConsumerWidget {
  const CineWaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(theme.seed),
      darkTheme: buildDarkTheme(theme.seed),
      themeMode: theme.mode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
