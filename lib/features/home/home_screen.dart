import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/mock_data.dart';
import '../../data/movie_repository.dart';
import '../../state/progress_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/shimmer.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/movie_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(moviesProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: moviesAsync.when(
        loading: () => const _HomeSkeleton(),
        error: (e, _) => EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Something went wrong',
          message: 'The catalog could not be loaded. Give it another shot.',
          action: FilledButton.icon(
            onPressed: () => ref.invalidate(moviesProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ),
        data: (movies) {
          final byId = {for (final m in movies) m.id: m};
          final trending =
              movies.where((m) => m.isTrending).toList(growable: false);
          final fresh =
              movies.where((m) => m.isNew).toList(growable: false);
          final top10 = [...movies]..sort((a, b) => b.rating.compareTo(a.rating));
          final continueEntries = ref
              .watch(progressProvider)
              .entries
              .where((e) => byId.containsKey(e.key))
              .toList(growable: false);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                toolbarHeight: 72,
                backgroundColor: scheme.surface.withValues(alpha: 0.88),
                surfaceTintColor: Colors.transparent,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: const SizedBox.expand(),
                  ),
                ),
                title: const BrandMark(size: 34, withWordmark: true),
                actions: [
                  IconButton(
                    tooltip: 'Explore',
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () => context.go('/explore'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16, left: 4),
                    child: GestureDetector(
                      onTap: () => context.go('/settings'),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            scheme.primary.withValues(alpha: 0.22),
                        child: Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeroCarousel(
                      items: trending.isNotEmpty
                          ? trending
                          : movies.take(5).toList(growable: false),
                    ),
                    if (continueEntries.isNotEmpty) ...[
                      SectionHeader(title: 'Continue Watching'),
                      MovieRow(
                        items: [
                          for (final e in continueEntries) byId[e.key]!
                        ],
                        progress: {
                          for (final e in continueEntries) e.key: e.value
                        },
                        cardWidth: 168,
                      ),
                    ],
                    SectionHeader(
                      title: 'Trending Now',
                      trailing: TextButton(
                        onPressed: () => context.go('/explore'),
                        child: const Text('See all'),
                      ),
                    ),
                    MovieRow(items: trending),
                    Top10Row(items: top10.take(10).toList(growable: false)),
                    SectionHeader(title: 'New & Noteworthy'),
                    MovieRow(items: fresh),
                    for (final g in kHomeGenres) ...[
                      SectionHeader(title: g),
                      MovieRow(
                        items: movies
                            .where((m) => m.hasGenre(g))
                            .toList(growable: false),
                      ),
                    ],
                    const SizedBox(height: 26),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            AppConstants.appName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${movies.length} titles  •  ${AppConstants.tagline}  •  v${AppConstants.appVersion}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: scheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 88),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerBox(height: 320, radius: 24),
          ),
          const SizedBox(height: 34),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: ShimmerBox(
              width: 160,
              height: 18,
              radius: 8,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 250,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, __) => const ShimmerBox(
                width: 156,
                height: 234,
                radius: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
