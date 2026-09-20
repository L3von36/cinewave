import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bundled display typeface (see pubspec assets).
const String kFontFamily = 'Outfit';

/// Default brand seed used before the user picks an accent.
const Color kDefaultSeed = Color(0xFF7C6CFF);

/// Accent palette offered in Settings (Material You style seeding).
const List<Color> kAccentChoices = [
  Color(0xFF7C6CFF), // Violet
  Color(0xFF22D3EE), // Cyan
  Color(0xFFFB7185), // Rose
  Color(0xFFFBBF24), // Amber
  Color(0xFF34D399), // Emerald
  Color(0xFF818CF8), // Indigo
];

ThemeData buildDarkTheme(Color seed) {
  final scheme =
      ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark)
          .copyWith(
    surface: const Color(0xFF0B0D12),
    surfaceContainerLowest: const Color(0xFF06070B),
    surfaceContainerLow: const Color(0xFF111319),
    surfaceContainer: const Color(0xFF16181F),
    surfaceContainerHigh: const Color(0xFF1D2028),
    surfaceContainerHighest: const Color(0xFF242833),
  );
  return _build(scheme);
}

ThemeData buildLightTheme(Color seed) {
  final scheme =
      ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
  return _build(scheme);
}

ThemeData _build(ColorScheme scheme) {
  final dark = scheme.brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    fontFamily: kFontFamily,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: dark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent),
      titleTextStyle: TextStyle(
        fontFamily: kFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface.withValues(alpha: 0.94),
      indicatorColor: scheme.primary.withValues(alpha: 0.18),
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: kFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: 0.18),
      selectedIconTheme: IconThemeData(color: scheme.primary),
      selectedLabelTextStyle: TextStyle(
        fontFamily: kFontFamily,
        color: scheme.primary,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontFamily: kFontFamily,
        color: scheme.onSurfaceVariant,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(
        fontFamily: kFontFamily,
        fontWeight: FontWeight.w500,
        color: scheme.onInverseSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.5),
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      labelStyle: TextStyle(
        fontFamily: kFontFamily,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withValues(alpha: 0.16),
      trackHeight: 4,
    ),
  );
}
