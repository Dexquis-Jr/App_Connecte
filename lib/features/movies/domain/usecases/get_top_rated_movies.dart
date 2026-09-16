import '../../../../core/error/failures.dart';
import '../entities/movie.dart';
import '../repositories/movies_repository.dart';

class GetTopRatedMovies {
  final MoviesRepository repository;
  GetTopRatedMovies(this.repository);

  Future<RepositoryResult<List<Movie>>> call({int page = 1}) => repository.getTopRatedMovies(page: page);
}
