import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/models/movie.dart';
import 'common.dart';
import 'poster_art.dart';

/// Tappable poster card with hover lift, NEW badge, rating badge and an
/// optional continue-watching progress bar.
class MovieCard extends StatefulWidget {
  final Movie movie;
  final double? progress;
  final double width;
  final EdgeInsetsGeometry margin;

  const MovieCard({
    super.key,
    required this.movie,
    this.progress,
    this.width = 156,
    this.margin = EdgeInsets.zero,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/title/${movie.id}');
        },
        child: AnimatedScale(
          scale: _hover ? 1.05 : 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.width,
            margin: widget.margin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterArt(movie: movie),
                      if (movie.isNew)
                        Positioned(top: 8, left: 8, child: const NewBadge()),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: RatingBadge(rating: movie.rating),
                      ),
                      if (widget.progress != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 4,
                            color: Colors.white.withValues(alpha: 0.25),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: widget.progress!.clamp(0.0, 1.0),
                              child: Container(color: scheme.primary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    '${movie.year}  •  ${movie.durationLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
