import 'package:flutter/material.dart';

/// One episode of a [Season].
@immutable
class Episode {
  final int number;
  final String title;
  final int minutes;

  const Episode({required this.number, required this.title, this.minutes = 42});
}

/// A season containing a list of [Episode]s.
@immutable
class Season {
  final int number;
  final List<Episode> episodes;

  const Season({required this.number, required this.episodes});
}

/// A movie or series in the CineWave catalog.
///
/// Poster/backdrop art is never loaded from the network: every title carries
/// a gradient palette that drives the procedural artwork shown across the app.
@immutable
class Movie {
  final String id;
  final String title;
  final String tagline;
  final String synopsis;
  final int year;
  final double rating;
  final int runtimeMinutes;
  final List<String> genres;
  final String ageRating;
  final List<String> cast;
  final bool isSeries;
  final List<Season> seasons;
  final bool isTrending;
  final bool isNew;
  final String quality;
  final Color posterTop;
  final Color posterBottom;

  const Movie({
    required this.id,
    required this.title,
    required this.tagline,
    required this.synopsis,
    required this.year,
    required this.rating,
    required this.runtimeMinutes,
    required this.genres,
    required this.ageRating,
    required this.cast,
    this.isSeries = false,
    this.seasons = const [],
    this.isTrending = false,
    this.isNew = false,
    this.quality = '4K HDR',
    required this.posterTop,
    required this.posterBottom,
  });

  String get primaryGenre => genres.first;

  String get durationLabel {
    if (isSeries) {
      final n = seasons.length;
      return '$n season${n > 1 ? 's' : ''}';
    }
    final h = runtimeMinutes ~/ 60;
    final m = runtimeMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Total episode count across all seasons (0 for movies).
  int get episodeCount =>
      seasons.fold(0, (total, s) => total + s.episodes.length);

  /// True if [genre] appears anywhere in this title's genres.
  bool hasGenre(String genre) => genres.contains(genre);
}
