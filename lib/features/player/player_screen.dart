import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils.dart';
import '../../data/mock_data.dart';
import '../../data/models/movie.dart';
import '../../data/movie_repository.dart';
import '../../state/progress_provider.dart';
import '../../widgets/poster_art.dart';
import 'playback.dart';
import 'player_progress_bar.dart';

/// Cinematic player: real streaming video on supported platforms with an
/// automatic simulated-playback fallback, custom controls, double-tap seek,
/// speed picker, fullscreen on handsets and autoplay next episode.
class PlayerScreen extends ConsumerStatefulWidget {
  final String id;
  final int? episode;

  const PlayerScreen({super.key, required this.id, this.episode});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  Playback? _playback;
  Episode? _episode;
  bool _controlsVisible = true;
  bool _finishedHandled = false;
  double _speed = 1;
  double _lastSavedProgress = -1;
  Timer? _hideTimer;
  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    final playback = _playback;
    if (_listener != null && playback != null) {
      playback.state.removeListener(_listener!);
    }
    _hideTimer?.cancel();
    playback?.dispose();
    if (_isHandset) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  bool get _isHandset =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  List<Episode> _flatEpisodes(Movie movie) =>
      [for (final s in movie.seasons) ...s.episodes];

  int _globalIndex(Movie movie, Episode episode) =>
      _flatEpisodes(movie).indexOf(episode) + 1;

  Episode? _nextEpisode(Movie movie) {
    if (!movie.isSeries) return null;
    final eps = _flatEpisodes(movie);
    if (_episode == null) return eps.isNotEmpty ? eps.first : null;
    final idx =
        eps.indexWhere((e) => identical(e, _episode));
    if (idx < 0 || idx + 1 >= eps.length) return null;
    return eps[idx + 1];
  }

  Future<void> _bootstrap() async {
    final movie = ref.read(movieByIdProvider(widget.id));
    if (movie == null) return;

    if (movie.isSeries && widget.episode != null && widget.episode! >= 1) {
      final eps = _flatEpisodes(movie);
      if (widget.episode! <= eps.length) {
        _episode = eps[widget.episode! - 1];
      }
    }

    final fallback =
        Duration(minutes: _episode?.minutes ?? movie.runtimeMinutes);
    final playback = await createPlayback(streamFor(movie.id), fallback);
    if (!mounted) {
      await playback.dispose();
      return;
    }
    _listener = () => _onStateChanged(movie);
    playback.state.addListener(_listener!);
    setState(() => _playback = playback);
    await playback.play();
    _scheduleHide();
  }

  void _onStateChanged(Movie movie) {
    final s = _playback?.state.value;
    if (s == null || !mounted) return;
    if (s.completed && !_finishedHandled) {
      _finishedHandled = true;
      _hideTimer?.cancel();
      setState(() => _controlsVisible = true);
      ref.read(progressProvider.notifier).set(movie.id, 1.0);
      final autoplay =
          ref.read(sharedPreferencesProvider).getBool('autoplay_next') ??
              true;
      if (autoplay && movie.isSeries) {
        final next = _nextEpisode(movie);
        if (next != null && !identical(next, _episode)) {
          context.pushReplacement(
              '/title/${movie.id}/play?ep=${_globalIndex(movie, next)}');
        }
      }
    } else if (!s.completed && s.duration > Duration.zero) {
      final p = s.position.inMilliseconds /
          max(1, s.duration.inMilliseconds);
      if ((p - _lastSavedProgress).abs() >= 0.01) {
        _lastSavedProgress = p;
        ref.read(progressProvider.notifier).set(movie.id, p);
      }
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted &&
          (_playback?.state.value.playing ?? false) &&
          _controlsVisible) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleHide();
  }

  void _togglePlay() {
    final s = _playback?.state.value;
    if (s == null) return;
    HapticFeedback.lightImpact();
    if (s.completed) {
      _replay();
      return;
    }
    if (s.playing) {
      _playback!.pause();
    } else {
      _playback!.play();
    }
    _scheduleHide();
  }

  void _replay() {
    _finishedHandled = false;
    _playback?.seek(Duration.zero);
    _playback?.play();
    _scheduleHide();
  }

  void _seekBy(Duration delta) {
    final s = _playback?.state.value;
    if (s == null) return;
    _playback!.seek(s.position + delta);
    HapticFeedback.selectionClick();
    _scheduleHide();
  }

  void _onDoubleTap(TapDownDetails d) {
    final w = context.screenW;
    final dx = d.localPosition.dx;
    if (dx < w / 3) {
      _seekBy(const Duration(seconds: -10));
    } else if (dx > w * 2 / 3) {
      _seekBy(const Duration(seconds: 10));
    }
  }

  void _toggleFullscreen() {
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    if (landscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  Future<void> _pickSpeed() async {
    final selected = await showModalBottomSheet<double>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Playback speed',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            for (final s in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
              ListTile(
                title: Text('${s}x'),
                trailing:
                    s == _speed ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.pop(context, s),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _speed = selected);
      await _playback?.setSpeed(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = ref.watch(movieByIdProvider(widget.id));
    if (movie == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final state = _playback?.state.value ?? const PlaybackState();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        onDoubleTapDown: _onDoubleTap,
        onDoubleTap: () {},
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildStage(movie, state),
            AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TopBar(
                      movie: movie,
                      episode: _episode,
                      quality: movie.quality,
                      onBack: () {
                        if (context.canPop()) context.pop();
                      },
                    ),
                    _CenterPlayButton(
                      playing: state.playing,
                      buffering: state.buffering,
                      onTap: _togglePlay,
                    ),
                    _BottomBar(
                      state: state,
                      speed: _speed,
                      showFullscreen: _isHandset,
                      onSeek: (d) {
                        _playback?.seek(d);
                        _scheduleHide();
                      },
                      onSpeed: _pickSpeed,
                      onFullscreen: _toggleFullscreen,
                    ),
                  ],
                ),
              ),
            ),
            if (state.completed)
              _CompletedOverlay(
                isSeries: movie.isSeries,
                hasNext: _nextEpisode(movie) != null &&
                    !identical(_nextEpisode(movie), _episode),
                onReplay: _replay,
                onNext: () {
                  final next = _nextEpisode(movie);
                  if (next == null) return;
                  context.pushReplacement(
                      '/title/${movie.id}/play?ep=${_globalIndex(movie, next)}');
                },
                onClose: () {
                  if (context.canPop()) context.pop();
                },
              ),
            if (state.simulated && _controlsVisible)
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom + 96,
                    left: 16,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Demo mode — simulated playback',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStage(Movie movie, PlaybackState state) {
    final playback = _playback;
    if (playback == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    if (playback is VideoPlayback) {
      return Center(
        child: AspectRatio(
          aspectRatio: playback.aspectRatio,
          child: playback.view,
        ),
      );
    }
    return _SimulatedStage(movie: movie);
  }
}

/// Slow Ken Burns pan over the procedural backdrop while "playing" in
/// simulated mode.
class _SimulatedStage extends StatefulWidget {
  final Movie movie;

  const _SimulatedStage({required this.movie});

  @override
  State<_SimulatedStage> createState() => _SimulatedStageState();
}

class _SimulatedStageState extends State<_SimulatedStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _drift,
          builder: (context, _) {
            return Transform.scale(
              scale: 1.05 + _drift.value * 0.12,
              child: Opacity(
                opacity: 0.42,
                child: PosterArt(
                  movie: widget.movie,
                  variant: PosterVariant.backdrop,
                  showText: false,
                ),
              ),
            );
          },
        ),
        Center(
          child: Text(
            widget.movie.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.22),
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final Movie movie;
  final Episode? episode;
  final String quality;
  final VoidCallback onBack;

  const _TopBar({
    required this.movie,
    required this.episode,
    required this.quality,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.65),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.only(bottom: 28),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _PlayerCircleButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBack,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (episode != null)
                      Text(
                        'Episode ${episode!.number}  •  ${episode!.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12.5,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  quality,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterPlayButton extends StatelessWidget {
  final bool playing;
  final bool buffering;
  final VoidCallback onTap;

  const _CenterPlayButton({
    required this.playing,
    required this.buffering,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: buffering
          ? const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3),
            )
          : GestureDetector(
              onTap: onTap,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Container(
                  key: ValueKey(playing),
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Icon(
                    playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final PlaybackState state;
  final double speed;
  final bool showFullscreen;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onSpeed;
  final VoidCallback onFullscreen;

  const _BottomBar({
    required this.state,
    required this.speed,
    required this.showFullscreen,
    required this.onSeek,
    required this.onSpeed,
    required this.onFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.75),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.only(top: 30),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlayerProgressBar(state: state, onSeek: onSeek),
              Row(
                children: [
                  TextButton(
                    onPressed: onSpeed,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      '$speed x',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (showFullscreen)
                    IconButton(
                      tooltip: 'Fullscreen',
                      onPressed: onFullscreen,
                      icon: const Icon(Icons.fullscreen_rounded,
                          color: Colors.white, size: 28),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedOverlay extends StatelessWidget {
  final bool isSeries;
  final bool hasNext;
  final VoidCallback onReplay;
  final VoidCallback? onNext;
  final VoidCallback onClose;

  const _CompletedOverlay({
    required this.isSeries,
    required this.hasNext,
    required this.onReplay,
    required this.onNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration_rounded,
                color: Colors.amberAccent, size: 56),
            const SizedBox(height: 12),
            const Text(
              "That's a wrap.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: onReplay,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Replay'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                ),
                const SizedBox(width: 12),
                if (isSeries && hasNext)
                  FilledButton.icon(
                    onPressed: onNext,
                    icon: const Icon(Icons.skip_next_rounded),
                    label: const Text('Next episode'),
                  )
                else
                  FilledButton(
                    onPressed: onClose,
                    child: const Text('Back to details'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PlayerCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}
