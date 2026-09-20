import 'package:flutter/material.dart';

/// Formats a duration as `m:ss` or `h:mm:ss`.
String formatClock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// Formats "remaining time" labels for continue-watching progress bars.
String formatRemaining(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h > 0) return '${h}h ${m}m left';
  return '$m min left';
}

extension WindowX on BuildContext {
  double get screenW => MediaQuery.sizeOf(this).width;
  double get screenH => MediaQuery.sizeOf(this).height;
  bool get isCompact => screenW < 600;
  bool get isMedium => screenW >= 600 && screenW < 1024;
  bool get isExpanded => screenW >= 1024;
}
