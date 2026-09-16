import '../../../../core/error/failures.dart';
import '../entities/movie.dart';
import '../repositories/movies_repository.dart';

class GetPopularMovies {
  final MoviesRepository repository;
  GetPopularMovies(this.repository);

  Future<RepositoryResult<List<Movie>>> call({int page = 1}) => repository.getPopularMovies(page: page);
}
