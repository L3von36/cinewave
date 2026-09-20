import 'dart:math';

import 'package:flutter/material.dart';

import '../data/models/movie.dart';

/// How the procedural artwork is framed.
enum PosterVariant { poster, backdrop }

/// Procedural, deterministic poster/backdrop artwork.
///
/// Every title renders a unique cinematic composition derived from its
/// palette + id — no network images, no asset files, works fully offline.
class PosterArt extends StatelessWidget {
  final Movie movie;
  final PosterVariant variant;
  final bool showText;

  const PosterArt({
    super.key,
    required this.movie,
    this.variant = PosterVariant.poster,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final wide = variant == PosterVariant.backdrop;
    return ClipRRect(
      borderRadius: BorderRadius.circular(wide ? 24 : 18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _CinemaPainter(
              top: movie.posterTop,
              bottom: movie.posterBottom,
              seed: movie.id.hashCode,
            ),
          ),
          if (showText)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: wide ? 20 : 15,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.year}  •  ${movie.primaryGenre}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: wide ? 13 : 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CinemaPainter extends CustomPainter {
  final Color top;
  final Color bottom;
  final int seed;

  _CinemaPainter({required this.top, required this.bottom, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base vertical gradient.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );

    final rnd = Random(seed);

    // Large soft-light orbs.
    for (var i = 0; i < 4; i++) {
      final c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height * 0.75,
      );
      final r = size.width * (0.16 + rnd.nextDouble() * 0.32);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = Color.fromRGBO(255, 255, 255, 0.04 + rnd.nextDouble() * 0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
      );
    }

    // Diagonal light beam.
    final beam = Path()
      ..moveTo(size.width * 0.12, 0)
      ..lineTo(size.width * 0.42, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.62, size.height)
      ..close();
    canvas.drawPath(
      beam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    // Film grain.
    final grain = Paint()..color = Colors.white.withValues(alpha: 0.04);
    for (var i = 0; i < 240; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        rnd.nextDouble() * 1.2 + 0.3,
        grain,
      );
    }

    // Vignette.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: size.width * 0.9,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.38)],
          stops: const [0.55, 1.0],
        ).createShader(rect),
    );

    // Bottom scrim so overlay text stays legible.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: const Alignment(0, 0.35),
          colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _CinemaPainter old) {
    return old.top != top || old.bottom != bottom || old.seed != seed;
  }
}
