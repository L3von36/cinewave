import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/movie.dart';
import '../../data/movie_repository.dart';
import '../../state/watchlist_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/poster_art.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  late final ConfettiController _confetti = ConfettiController(
    duration: const Duration(milliseconds: 900),
  );
  int _season = 1;

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _toggleWatchlist(Movie movie) {
    final adding =
        !ref.read(watchlistProvider).contains(movie.id);
    ref.read(watchlistProvider.notifier).toggle(movie.id);
    HapticFeedback.mediumImpact();
    if (adding) _confetti.play();
  }

  @override
  Widget build(BuildContext context) {
    final movie = ref.watch(movieByIdProvider(widget.id));
    if (movie == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final inList = ref.watch(watchlistProvider).contains(movie.id);
    final similar = ref.watch(similarProvider(movie.id));
    final backdropH = (width * 0.44).clamp(230.0, 400.0);
    final gridCross = width < 600 ? 3 : width < 900 ? 4 : 6;
    final currentSeason = movie.seasons
        .where((s) => s.number == _season)
        .toList(growable: false);
    final flatEpisodes = [for (final s in movie.seasons) ...s.episodes];

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: backdropH,
                pinned: true,
                backgroundColor: scheme.surface,
                surfaceTintColor: Colors.transparent,
                leading: _CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => context.pop(),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _CircleIconButton(
                      icon: inList
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      onTap: () => _toggleWatchlist(movie),
                      iconColor: inList ? scheme.primary : null,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterArt(
                        movie: movie,
                        variant: PosterVariant.backdrop,
                        showText: false,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              scheme.surface,
                              scheme.surface.withValues(alpha: 0.0),
                            ],
                            stops: const [0, 0.5],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(
                          fontSize: (width / 28).clamp(26.0, 36.0),
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          height: 1.08,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.tagline,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          RatingBadge(rating: movie.rating),
                          MetaChip(label: '${movie.year}'),
                          MetaChip(label: movie.durationLabel),
                          MetaChip(label: movie.ageRating),
                          MetaChip(label: movie.quality),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => context.push(
                                  '/title/${movie.id}/play'),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Play'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                textStyle: const TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton.tonalIcon(
                            onPressed: () => _toggleWatchlist(movie),
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(
                                      scale: anim, child: child),
                              child: Icon(
                                inList
                                    ? Icons.check_rounded
                                    : Icons.add_rounded,
                                key: ValueKey(inList),
                              ),
                            ),
                            label: Text(inList ? 'In list' : 'Watchlist'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        movie.synopsis,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          color: scheme.onSurface.withValues(alpha: 0.88),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final g in movie.genres) MetaChip(label: g),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Cast',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 108,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: movie.cast.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, i) {
                            final name = movie.cast[i];
                            final parts = name.split(' ');
                            final initials = parts
                                .take(2)
                                .map((p) => p.isNotEmpty ? p[0] : '')
                                .join();
                            return SizedBox(
                              width: 76,
                              child: Column(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          movie.posterTop,
                                          movie.posterBottom,
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        initials.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      height: 1.2,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (movie.isSeries &&
                          movie.seasons.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Episodes',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final s in movie.seasons)
                              ChoiceChip(
                                label: Text('Season ${s.number}'),
                                selected: _season == s.number,
                                showCheckmark: false,
                                onSelected: (_) =>
                                    setState(() => _season = s.number),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (currentSeason.isNotEmpty)
                          ...currentSeason.first.episodes.map(
                            (ep) => _EpisodeTile(
                              movie: movie,
                              episode: ep,
                              palette: [movie.posterTop, movie.posterBottom],
                              onPlay: () => context.push(
                                  '/title/${movie.id}/play?ep=${flatEpisodes.indexOf(ep) + 1}'),
                            ),
                          ),
                      ],
                      if (similar.isNotEmpty) ...[
                        const SizedBox(height: 26),
                        Text(
                          'More Like This',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCross,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.55,
                          ),
                          itemCount: similar.length,
                          itemBuilder: (context, i) => MovieCard(
                            movie: similar[i],
                            width: double.infinity,
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Confetti burst when a title is added to the watchlist.
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 22,
              minBlastForce: 6,
              emissionFrequency: 0.06,
              numberOfParticles: 24,
              gravity: 0.28,
              shouldLoop: false,
              colors: const [
                Color(0xFF7C6CFF),
                Color(0xFF22D3EE),
                Color(0xFFFFC94D),
                Color(0xFFFB7185),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: scheme.surface.withValues(alpha: 0.55),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 22, color: iconColor ?? scheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final Movie movie;
  final Episode episode;
  final List<Color> palette;
  final VoidCallback onPlay;

  const _EpisodeTile({
    required this.movie,
    required this.episode,
    required this.palette,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: palette,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${episode.number}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${episode.minutes} min  •  ${movie.title}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Play episode',
            onPressed: onPlay,
            icon: Icon(
              Icons.play_circle_outline_rounded,
              size: 30,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
