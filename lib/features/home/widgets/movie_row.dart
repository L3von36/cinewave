import 'package:flutter/material.dart';

import '../../../data/models/movie.dart';
import '../../../widgets/movie_card.dart';

/// Horizontal rail of poster cards.
class MovieRow extends StatelessWidget {
  final List<Movie> items;
  final Map<String, double> progress;
  final double cardWidth;

  const MovieRow({
    super.key,
    required this.items,
    this.progress = const {},
    this.cardWidth = 156,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 262,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final movie = items[i];
          return MovieCard(
            movie: movie,
            width: cardWidth,
            progress: progress[movie.id],
          );
        },
      ),
    );
  }
}

/// Netflix-style "Top 10" rail with giant outlined numerals behind posters.
class Top10Row extends StatelessWidget {
  final List<Movie> items;

  const Top10Row({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 258,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 26),
        itemBuilder: (context, i) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 46),
                child: MovieCard(movie: items[i], width: 150),
              ),
              Positioned(
                left: -8,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 112,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2.5
                      ..color = scheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
