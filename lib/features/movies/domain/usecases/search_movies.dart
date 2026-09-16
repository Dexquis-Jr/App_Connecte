import '../../../../core/error/failures.dart';
import '../entities/movie.dart';
import '../repositories/movies_repository.dart';

class SearchMovies {
  final MoviesRepository repository;
  SearchMovies(this.repository);

  Future<RepositoryResult<List<Movie>>> call(String query) => repository.searchMovies(query);
}
