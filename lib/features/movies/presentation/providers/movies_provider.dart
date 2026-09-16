import 'package:flutter/foundation.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/get_top_rated_movies.dart';
import '../../domain/usecases/search_movies.dart';

enum LoadState { initial, loading, loaded, error }

class MovieListState {
  LoadState state = LoadState.initial;
  List<Movie> movies = [];
  String? errorMessage;
  bool isFromCache = false;
}

/// One provider drives all three data screens (popular / top rated /
/// search) to avoid duplicating the same loading/error/cache-banner logic
/// three times.
class MoviesProvider extends ChangeNotifier {
  final GetPopularMovies getPopularMovies;
  final GetTopRatedMovies getTopRatedMovies;
  final SearchMovies searchMoviesUseCase;

  MoviesProvider({
    required this.getPopularMovies,
    required this.getTopRatedMovies,
    required this.searchMoviesUseCase,
  });

  final popular = MovieListState();
  final topRated = MovieListState();
  final search = MovieListState();

  Future<void> loadPopular() async {
    popular.state = LoadState.loading;
    notifyListeners();
    final result = await getPopularMovies();
    if (result.isSuccess) {
      popular
        ..movies = result.data ?? []
        ..isFromCache = result.isFromCache
        ..state = LoadState.loaded;
    } else {
      popular
        ..errorMessage = result.failure?.message
        ..state = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadTopRated() async {
    topRated.state = LoadState.loading;
    notifyListeners();
    final result = await getTopRatedMovies();
    if (result.isSuccess) {
      topRated
        ..movies = result.data ?? []
        ..isFromCache = result.isFromCache
        ..state = LoadState.loaded;
    } else {
      topRated
        ..errorMessage = result.failure?.message
        ..state = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> runSearch(String query) async {
    if (query.trim().isEmpty) {
      search.movies = [];
      search.state = LoadState.initial;
      notifyListeners();
      return;
    }
    search.state = LoadState.loading;
    notifyListeners();
    final result = await searchMoviesUseCase(query.trim());
    if (result.isSuccess) {
      search
        ..movies = result.data ?? []
        ..isFromCache = result.isFromCache
        ..state = LoadState.loaded;
    } else {
      search
        ..errorMessage = result.failure?.message
        ..state = LoadState.error;
    }
    notifyListeners();
  }
}
