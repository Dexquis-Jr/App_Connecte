import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../models/movie_model.dart';

abstract class MoviesLocalDataSource {
  Future<void> cachePopularMovies(List<MovieModel> movies);
  Future<List<MovieModel>> getCachedPopularMovies();

  Future<void> cacheTopRatedMovies(List<MovieModel> movies);
  Future<List<MovieModel>> getCachedTopRatedMovies();

  Future<void> cacheSearchResults(String query, List<MovieModel> movies);
  Future<List<MovieModel>> getCachedSearchResults(String query);
}

class MoviesLocalDataSourceImpl implements MoviesLocalDataSource {
  Box get _popularBox => Hive.box(HiveBoxes.popularMoviesBox);
  Box get _topRatedBox => Hive.box(HiveBoxes.topRatedMoviesBox);
  Box get _searchBox => Hive.box(HiveBoxes.searchMoviesBox);

  @override
  Future<void> cachePopularMovies(List<MovieModel> movies) async {
    await _popularBox.put('items', movies.map((m) => m.toJson()).toList());
  }

  @override
  Future<List<MovieModel>> getCachedPopularMovies() => _readList(_popularBox, 'items');

  @override
  Future<void> cacheTopRatedMovies(List<MovieModel> movies) async {
    await _topRatedBox.put('items', movies.map((m) => m.toJson()).toList());
  }

  @override
  Future<List<MovieModel>> getCachedTopRatedMovies() => _readList(_topRatedBox, 'items');

  @override
  Future<void> cacheSearchResults(String query, List<MovieModel> movies) async {
    await _searchBox.put(query.toLowerCase(), movies.map((m) => m.toJson()).toList());
  }

  @override
  Future<List<MovieModel>> getCachedSearchResults(String query) => _readList(_searchBox, query.toLowerCase());

  Future<List<MovieModel>> _readList(Box box, String key) async {
    final raw = box.get(key);
    if (raw == null) {
      throw CacheException();
    }
    final list = (raw as List)
        .map((e) => MovieModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return list;
  }
}
