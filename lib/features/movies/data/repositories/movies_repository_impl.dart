import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movies_repository.dart';
import '../datasources/movies_local_datasource.dart';
import '../datasources/movies_remote_datasource.dart';

/// Offline-first strategy:
/// 1. If connected: fetch from network, cache the result, return it.
/// 2. If the network call fails (or there's no connectivity at all): fall
///    back to whatever is cached and mark the result `isFromCache = true`
///    so the UI can show a "showing cached data" banner.
/// 3. If neither network nor cache has data: return a Failure with a
///    user-facing message.
class MoviesRepositoryImpl implements MoviesRepository {
  final MoviesRemoteDataSource remoteDataSource;
  final MoviesLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MoviesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<RepositoryResult<List<Movie>>> getPopularMovies({int page = 1}) {
    return _fetchWithCacheFallback(
      fetchRemote: () => remoteDataSource.getPopularMovies(page: page),
      cacheRemote: (movies) => localDataSource.cachePopularMovies(movies),
      readCache: () => localDataSource.getCachedPopularMovies(),
    );
  }

  @override
  Future<RepositoryResult<List<Movie>>> getTopRatedMovies({int page = 1}) {
    return _fetchWithCacheFallback(
      fetchRemote: () => remoteDataSource.getTopRatedMovies(page: page),
      cacheRemote: (movies) => localDataSource.cacheTopRatedMovies(movies),
      readCache: () => localDataSource.getCachedTopRatedMovies(),
    );
  }

  @override
  Future<RepositoryResult<List<Movie>>> searchMovies(String query) {
    return _fetchWithCacheFallback(
      fetchRemote: () => remoteDataSource.searchMovies(query),
      cacheRemote: (movies) => localDataSource.cacheSearchResults(query, movies),
      readCache: () => localDataSource.getCachedSearchResults(query),
    );
  }

  Future<RepositoryResult<List<Movie>>> _fetchWithCacheFallback<T extends Movie>({
    required Future<List<T>> Function() fetchRemote,
    required Future<void> Function(List<T>) cacheRemote,
    required Future<List<T>> Function() readCache,
  }) async {
    final connected = await networkInfo.isConnected;

    if (connected) {
      try {
        final remoteMovies = await fetchRemote();
        await cacheRemote(remoteMovies);
        return RepositoryResult.success(List<Movie>.from(remoteMovies));
      } on NetworkException {
        return _fallbackToCache(readCache);
      } on ServerException catch (e) {
        // Server reachable but errored (e.g. bad API key) — still try cache
        // before giving up, but surface the server message if cache is empty.
        final cached = await _tryReadCache(readCache);
        if (cached != null) {
          return RepositoryResult.success(cached, isFromCache: true);
        }
        return RepositoryResult.error(ServerFailure(e.message));
      }
    } else {
      return _fallbackToCache(readCache);
    }
  }

  Future<RepositoryResult<List<Movie>>> _fallbackToCache<T extends Movie>(
    Future<List<T>> Function() readCache,
  ) async {
    final cached = await _tryReadCache(readCache);
    if (cached != null) {
      return RepositoryResult.success(cached, isFromCache: true);
    }
    return const RepositoryResult.error(
      NetworkFailure('No internet connection and no cached data available.'),
    );
  }

  Future<List<Movie>?> _tryReadCache<T extends Movie>(Future<List<T>> Function() readCache) async {
    try {
      final cached = await readCache();
      return List<Movie>.from(cached);
    } on CacheException {
      return null;
    }
  }
}
