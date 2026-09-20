import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Immutable snapshot of playback position/status.
class PlaybackState {
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final bool playing;
  final bool buffering;
  final bool completed;
  final bool simulated;

  const PlaybackState({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffered = Duration.zero,
    this.playing = false,
    this.buffering = false,
    this.completed = false,
    this.simulated = false,
  });

  PlaybackState copyWith({
    Duration? position,
    Duration? duration,
    Duration? buffered,
    bool? playing,
    bool? buffering,
    bool? completed,
  }) {
    return PlaybackState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      buffered: buffered ?? this.buffered,
      playing: playing ?? this.playing,
      buffering: buffering ?? this.buffering,
      completed: completed ?? this.completed,
      simulated: simulated,
    );
  }
}

/// Platform-agnostic playback surface used by the player UI.
abstract class Playback {
  ValueListenable<PlaybackState> get state;
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration to);
  Future<void> setSpeed(double speed);
  Future<void> dispose();
}

/// Timer-driven playback used when no real stream can be opened
/// (offline demos, desktop platforms without the video plugin wired in).
class SimulatedPlayback implements Playback {
  final ValueNotifier<PlaybackState> _notifier;
  Timer? _timer;
  double _speed = 1;

  SimulatedPlayback({required Duration total})
      : _notifier = ValueNotifier(
          PlaybackState(duration: total, simulated: true),
        );

  @override
  ValueListenable<PlaybackState> get state => _notifier;

  void _tick() {
    final s = _notifier.value;
    if (!s.playing || s.completed) return;
    final next =
        s.position + Duration(milliseconds: (100 * _speed).round());
    if (next >= s.duration) {
      _timer?.cancel();
      _timer = null;
      _notifier.value = s.copyWith(
        position: s.duration,
        playing: false,
        completed: true,
      );
    } else {
      _notifier.value = s.copyWith(position: next);
    }
  }

  @override
  Future<void> play() async {
    final s = _notifier.value;
    _notifier.value = s.copyWith(playing: true, completed: false);
    _timer ??= Timer.periodic(
        const Duration(milliseconds: 100), (_) => _tick());
  }

  @override
  Future<void> pause() async {
    _timer?.cancel();
    _timer = null;
    _notifier.value = _notifier.value.copyWith(playing: false);
  }

  @override
  Future<void> seek(Duration to) async {
    final dur = _notifier.value.duration;
    final clamped = to < Duration.zero
        ? Duration.zero
        : (to > dur ? dur : to);
    _notifier.value =
        _notifier.value.copyWith(position: clamped, completed: false);
  }

  @override
  Future<void> setSpeed(double speed) async {
    _speed = speed;
  }

  @override
  Future<void> dispose() async {
    _timer?.cancel();
    _notifier.dispose();
  }
}

/// Real video playback via the official video_player plugin
/// (Android, iOS, macOS, Web).
class VideoPlayback implements Playback {
  final VideoPlayerController _controller;
  late final ValueNotifier<PlaybackState> _notifier;

  VideoPlayback._(this._controller) {
    _notifier = ValueNotifier(_map(_controller.value));
    _controller.addListener(_sync);
  }

  static Future<VideoPlayback> create(String url) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    return VideoPlayback._(controller);
  }

  void _sync() => _notifier.value = _map(_controller.value);

  PlaybackState _map(VideoPlayerValue v) {
    return PlaybackState(
      position: v.position,
      duration: v.duration,
      buffered:
          v.buffered.isNotEmpty ? v.buffered.last.end : Duration.zero,
      playing: v.isPlaying,
      buffering: v.isBuffering,
      completed:
          v.duration > Duration.zero && v.position >= v.duration,
    );
  }

  double get aspectRatio => _controller.value.aspectRatio;

  Widget get view => VideoPlayer(_controller);

  @override
  ValueListenable<PlaybackState> get state => _notifier;

  @override
  Future<void> play() => _controller.play();

  @override
  Future<void> pause() => _controller.pause();

  @override
  Future<void> seek(Duration to) => _controller.seekTo(to);

  @override
  Future<void> setSpeed(double speed) =>
      _controller.setPlaybackSpeed(speed);

  @override
  Future<void> dispose() => _controller.dispose();
}

/// Tries a real stream first; falls back to simulated playback if the
/// network or the platform plugin is unavailable.
Future<Playback> createPlayback(
    String url, Duration fallbackDuration) async {
  VideoPlayerController? controller;
  try {
    controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize().timeout(const Duration(seconds: 8));
    return VideoPlayback._(controller);
  } catch (_) {
    try {
      await controller?.dispose();
    } catch (_) {/* ignore */}
    return SimulatedPlayback(total: fallbackDuration);
  }
}
