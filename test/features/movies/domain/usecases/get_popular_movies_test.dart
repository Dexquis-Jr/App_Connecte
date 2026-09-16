import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/search_movies.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

void main() {
  late MockMoviesRepository repository;

  setUp(() {
    repository = MockMoviesRepository();
  });

  final tMovie = const MovieModel(
    id: 42,
    title: 'The Matrix',
    overview: 'Welcome to the real world.',
    posterPath: '/matrix.jpg',
    voteAverage: 8.7,
    releaseDate: '1999-03-31',
  );

  test('GetPopularMovies delegates to repository.getPopularMovies with the given page', () async {
    final usecase = GetPopularMovies(repository);
    when(() => repository.getPopularMovies(page: 2))
        .thenAnswer((_) async => RepositoryResult.success([tMovie]));

    final result = await usecase(page: 2);

    expect(result.isSuccess, isTrue);
    expect(result.data, [tMovie]);
    verify(() => repository.getPopularMovies(page: 2)).called(1);
  });

  test('SearchMovies delegates to repository.searchMovies with the trimmed query', () async {
    final usecase = SearchMovies(repository);
    when(() => repository.searchMovies('matrix'))
        .thenAnswer((_) async => RepositoryResult.success([tMovie]));

    final result = await usecase('matrix');

    expect(result.isSuccess, isTrue);
    expect(result.data?.first.title, 'The Matrix');
    verify(() => repository.searchMovies('matrix')).called(1);
  });
}
