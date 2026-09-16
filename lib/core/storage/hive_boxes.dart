import 'package:hive_flutter/hive_flutter.dart';

/// Centralises Hive box names/opening. Cached items are stored as plain
/// `Map<String, dynamic>` (Hive supports primitive maps/lists natively),
/// which avoids requiring generated TypeAdapters / build_runner for this
/// sample project.
class HiveBoxes {
  static const String popularMoviesBox = 'popular_movies_cache';
  static const String topRatedMoviesBox = 'top_rated_movies_cache';
  static const String searchMoviesBox = 'search_movies_cache';
  static const String movieDetailBox = 'movie_detail_cache';
  static const String metaBox = 'cache_meta'; // stores last-fetched timestamps

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(popularMoviesBox),
      Hive.openBox(topRatedMoviesBox),
      Hive.openBox(searchMoviesBox),
      Hive.openBox(movieDetailBox),
      Hive.openBox(metaBox),
    ]);
  }
}
