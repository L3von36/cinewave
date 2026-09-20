import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/utils.dart';
import 'playback.dart';

/// Custom seek bar with buffered + position tracks and a draggable thumb.
class PlayerProgressBar extends StatelessWidget {
  final PlaybackState state;
  final ValueChanged<Duration> onSeek;

  const PlayerProgressBar({
    super.key,
    required this.state,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalMs = state.duration.inMilliseconds;
    final posFrac = totalMs > 0
        ? (state.position.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : 0.0;
    final bufFrac = totalMs > 0
        ? (state.buffered.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _seekTo(d.localPosition.dx, w),
          onHorizontalDragUpdate: (d) => _seekTo(d.localPosition.dx, w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: bufFrac,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: posFrac,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [scheme.primary, scheme.tertiary],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    left: posFrac * w - 7,
                    top: -4.5,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black38, blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    formatClock(state.position),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    totalMs > 0
                        ? '-${formatClock(state.duration - state.position)}'
                        : formatClock(state.duration),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _seekTo(double dx, double width) {
    final frac = (dx / max(1.0, width)).clamp(0.0, 1.0);
    onSeek(state.duration * frac);
  }
}
