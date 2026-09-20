import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils.dart';
import '../../../data/models/movie.dart';
import '../../../widgets/common.dart';
import '../../../widgets/poster_art.dart';

/// Auto-advancing featured carousel with parallax backdrop, scrims and
/// inline Play / Details actions.
class HeroCarousel extends StatefulWidget {
  final List<Movie> items;

  const HeroCarousel({super.key, required this.items});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.items.isEmpty) return;
      final next = (_index + 1) % widget.items.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final height = (context.screenW * 0.42).clamp(260.0, 470.0);
    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (i) {
              setState(() => _index = i);
              _startTimer();
            },
            itemBuilder: (context, i) {
              final movie = widget.items[i];
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  double delta = 0;
                  if (_controller.hasClients &&
                      _controller.position.haveDimensions &&
                      _controller.page != null) {
                    delta = _controller.page! - i;
                  }
                  final parallax = delta * 44;
                  final scale = (1 - delta.abs() * 0.05).clamp(0.94, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 12),
                    child: Transform.scale(
                      scale: scale,
                      child: GestureDetector(
                        onTap: () => context.push('/title/${movie.id}'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Transform.translate(
                                offset: Offset(parallax, 0),
                                child: PosterArt(
                                  movie: movie,
                                  variant: PosterVariant.backdrop,
                                  showText: false,
                                ),
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.74),
                                      Colors.transparent,
                                    ],
                                    stops: const [0, 0.62],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (movie.isNew) const NewBadge(),
                                        if (movie.isNew)
                                          const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.16),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            movie.quality,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.6,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      movie.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.6,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      movie.tagline,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(
                                            alpha: 0.82),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${movie.year}  •  ${movie.durationLabel}  •  ${movie.ageRating}',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white
                                            .withValues(alpha: 0.66),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        FilledButton.icon(
                                          onPressed: () => context.push(
                                              '/title/${movie.id}/play'),
                                          icon: const Icon(Icons
                                              .play_arrow_rounded),
                                          label: const Text('Play'),
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                scheme.primary,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        OutlinedButton.icon(
                                          onPressed: () => context
                                              .push('/title/${movie.id}'),
                                          icon: const Icon(
                                              Icons.info_outline_rounded),
                                          label: const Text('Details'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            side: const BorderSide(
                                                color: Colors.white38),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.items.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: i == _index ? 22 : 6,
                decoration: BoxDecoration(
                  color: i == _index
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
