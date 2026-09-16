import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/network/network_info.dart';
import 'package:movie_app/features/movies/data/datasources/movies_local_datasource.dart';
import 'package:movie_app/features/movies/data/datasources/movies_remote_datasource.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/data/repositories/movies_repository_impl.dart';

class MockRemoteDataSource extends Mock implements MoviesRemoteDataSource {}

class MockLocalDataSource extends Mock implements MoviesLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late MockNetworkInfo networkInfo;
  late MoviesRepositoryImpl repository;

  final tMovies = [
    const MovieModel(
      id: 1,
      title: 'Inception',
      overview: 'A mind-bending heist',
      posterPath: '/poster.jpg',
      voteAverage: 8.8,
      releaseDate: '2010-07-16',
    ),
  ];

  setUp(() {
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = MoviesRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );
    when(() => local.cachePopularMovies(any())).thenAnswer((_) async {});
    when(() => local.cacheTopRatedMovies(any())).thenAnswer((_) async {});
    when(() => local.cacheSearchResults(any(), any())).thenAnswer((_) async {});
  });

  group('getPopularMovies — online', () {
    test('fetches from remote, caches it, and returns fresh (non-cache) data',
        () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.getPopularMovies(page: 1))
          .thenAnswer((_) async => tMovies);

      final result = await repository.getPopularMovies();

      expect(result.isSuccess, isTrue);
      expect(result.isFromCache, isFalse);
      expect(result.data, tMovies);
      verify(() => local.cachePopularMovies(tMovies)).called(1);
    });
  });

  test('getTopRatedMovies fetches and caches remote data', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => remote.getTopRatedMovies(page: 1))
        .thenAnswer((_) async => tMovies);

    final result = await repository.getTopRatedMovies();

    expect(result.isSuccess, isTrue);
    expect(result.isFromCache, isFalse);
    expect(result.data, tMovies);
    verify(() => local.cacheTopRatedMovies(tMovies)).called(1);
  });

  test('searchMovies fetches and caches remote data', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => remote.searchMovies('matrix')).thenAnswer((_) async => tMovies);

    final result = await repository.searchMovies('matrix');

    expect(result.isSuccess, isTrue);
    expect(result.isFromCache, isFalse);
    expect(result.data, tMovies);
    verify(() => local.cacheSearchResults('matrix', tMovies)).called(1);
  });

  group('getPopularMovies — offline', () {
    test(
        'falls back to cached data and flags isFromCache when there is no connectivity',
        () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedPopularMovies())
          .thenAnswer((_) async => tMovies);

      final result = await repository.getPopularMovies();

      expect(result.isSuccess, isTrue);
      expect(result.isFromCache, isTrue);
      expect(result.data, tMovies);
      verifyNever(() => remote.getPopularMovies(page: any(named: 'page')));
    });

    test('returns NetworkFailure when offline and no cache exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedPopularMovies()).thenThrow(CacheException());

      final result = await repository.getPopularMovies();

      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<NetworkFailure>());
    });
  });

  group('getPopularMovies — online but server errors', () {
    test('falls back to cache when remote throws ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.getPopularMovies(page: 1))
          .thenThrow(ServerException('bad key', statusCode: 401));
      when(() => local.getCachedPopularMovies())
          .thenAnswer((_) async => tMovies);

      final result = await repository.getPopularMovies();

      expect(result.isSuccess, isTrue);
      expect(result.isFromCache, isTrue);
    });
  });
}
