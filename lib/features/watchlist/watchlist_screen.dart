import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/movie.dart';
import '../../data/movie_repository.dart';
import '../../state/watchlist_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/movie_card.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final ids = ref.watch(watchlistProvider);
    final movies = ref.watch(moviesProvider).value ?? const <Movie>[];
    final byId = {for (final m in movies) m.id: m};
    final items = [
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ];

    final crossAxis = MediaQuery.sizeOf(context).width < 600
        ? 2
        : MediaQuery.sizeOf(context).width < 900
            ? 3
            : MediaQuery.sizeOf(context).width < 1200
                ? 4
                : 6;

    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'Your list is empty',
              message:
                  'Tap the bookmark on any title and it will wait for you here.',
              action: FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Browse titles'),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        '${items.length} title${items.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: items.isEmpty
                            ? null
                            : () {
                                final pick = items[Random().nextInt(items.length)];
                                context.push('/title/${pick.id}/play');
                              },
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Surprise me'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxis,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.55,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) =>
                        MovieCard(movie: items[i], width: double.infinity),
                  ),
                ),
              ],
            ),
    );
  }
}
