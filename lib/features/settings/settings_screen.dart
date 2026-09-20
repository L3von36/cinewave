import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/movie_repository.dart';
import '../../state/progress_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/watchlist_provider.dart';
import '../../widgets/common.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final prefs = ref.watch(sharedPreferencesProvider);
    final theme = ref.watch(themeProvider);
    final autoplayNext = prefs.getBool('autoplay_next') ?? true;
    final quality = prefs.getString('default_quality') ?? 'Auto';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const SectionHeader(title: 'Appearance'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme mode',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded),
                      label: Text('Auto'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {theme.mode},
                  onSelectionChanged: (s) => ref
                      .read(themeProvider.notifier)
                      .setMode(s.first),
                ),
                const SizedBox(height: 20),
                const Text('Accent color',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final color in kAccentChoices)
                      _AccentDot(
                        color: color,
                        selected: theme.seed.toARGB32() == color.toARGB32(),
                        onTap: () => ref
                            .read(themeProvider.notifier)
                            .setSeed(color),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Playback'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Autoplay next episode',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Keep the story rolling'),
                  value: autoplayNext,
                  onChanged: (v) =>
                      prefs.setBool('autoplay_next', v),
                ),
                const SizedBox(height: 8),
                const Text('Default quality',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final q in ['Auto', '1080p', '720p', '480p'])
                      ChoiceChip(
                        label: Text(q),
                        selected: quality == q,
                        showCheckmark: false,
                        onSelected: (_) =>
                            prefs.setString('default_quality', q),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Data'),
          _Card(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.restart_alt_rounded,
                  color: scheme.primary),
              title: const Text('Reset demo data',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text(
                  'Clears watchlist, progress and preferences'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                await prefs.clear();
                ref.invalidate(watchlistProvider);
                ref.invalidate(progressProvider);
                ref.invalidate(themeProvider);
                ref.invalidate(moviesProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Demo data reset — fresh start!')),
                  );
                }
              },
            ),
          ),
          const SectionHeader(title: 'About'),
          _Card(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const BrandMark(size: 34),
                  title: const Text(
                    AppConstants.appName,
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  subtitle: Text(
                    '${AppConstants.tagline}  •  v${AppConstants.appVersion}',
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.code_rounded),
                  title: const Text('Source on GitHub',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text(AppConstants.repoUrl),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Open source licenses',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppConstants.appName,
                    applicationVersion: AppConstants.appVersion,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Built with Flutter & Material 3',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: child,
    );
  }
}

class _AccentDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _AccentDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(right: 12),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12)]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check_rounded,
                color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
