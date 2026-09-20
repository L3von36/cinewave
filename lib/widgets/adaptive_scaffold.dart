import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import 'common.dart';

/// Adaptive navigation shell:
///  - < 600px      -> bottom NavigationBar (phones)
///  - 600–1199px   -> NavigationRail with labels (tablets / portrait desktop)
///  - >= 1200px    -> extended NavigationRail with wordmark (desktop / wide web)
class AdaptiveScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveScaffold({super.key, required this.navigationShell});

  void _go(int i) => navigationShell.goBranch(
        i,
        initialLocation: i == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w < AppConstants.compactMax) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              height: 68,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _go,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search_rounded),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border_rounded),
                  selectedIcon: Icon(Icons.bookmark_rounded),
                  label: 'Watchlist',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          );
        }

        final extended = w >= AppConstants.extendedMin;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                _BrandRail(
                  extended: extended,
                  currentIndex: navigationShell.currentIndex,
                  onSelected: _go,
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: navigationShell),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BrandRail extends StatelessWidget {
  final bool extended;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _BrandRail({
    required this.extended,
    required this.currentIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelected,
      extended: extended,
      minExtendedWidth: 210,
      labelType:
          extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      groupAlignment: -0.85,
      leading: Padding(
        padding: const EdgeInsets.only(bottom: 22, top: 10, left: 6),
        child: BrandMark(size: extended ? 38 : 34, withWordmark: extended),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search_rounded),
          label: Text('Explore'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bookmark_border_rounded),
          selectedIcon: Icon(Icons.bookmark_rounded),
          label: Text('Watchlist'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: Text('Settings'),
        ),
      ],
    );
  }
}
