import '../../../../core/error/failures.dart';
import '../entities/movie.dart';

abstract class MoviesRepository {
  Future<RepositoryResult<List<Movie>>> getPopularMovies({int page = 1});
  Future<RepositoryResult<List<Movie>>> getTopRatedMovies({int page = 1});
  Future<RepositoryResult<List<Movie>>> searchMovies(String query);
}
