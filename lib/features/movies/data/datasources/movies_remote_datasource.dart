import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/tmdb_key.dart';
import '../../../../core/error/exceptions.dart';
import '../models/movie_model.dart';

abstract class MoviesRemoteDataSource {
  Future<List<MovieModel>> getPopularMovies({int page = 1});
  Future<List<MovieModel>> getTopRatedMovies({int page = 1});
  Future<List<MovieModel>> searchMovies(String query);
}

class MoviesRemoteDataSourceImpl implements MoviesRemoteDataSource {
  final Dio dio;
  MoviesRemoteDataSourceImpl(this.dio);

  @override
  Future<List<MovieModel>> getPopularMovies({int page = 1}) =>
      _fetch(ApiConstants.popularMoviesPath, {'page': page});

  @override
  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) =>
      _fetch(ApiConstants.topRatedMoviesPath, {'page': page});

  @override
  Future<List<MovieModel>> searchMovies(String query) =>
      _fetch(ApiConstants.searchMoviesPath, {'query': query});

  Future<List<MovieModel>> _fetch(
      String path, Map<String, dynamic> extraParams) async {
    try {
      final response = await dio.get(path, queryParameters: {
        'api_key': tmdbApiKey,
        'language': 'fr-FR',
        ...extraParams,
      });
      final results = (response.data['results'] as List<dynamic>? ?? []);
      return results
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      }
      if (e.response?.statusCode == 401) {
        throw ServerException(
            'Invalid TMDB API key — check lib/core/constants/tmdb_key.dart',
            statusCode: 401);
      }
      throw ServerException(
          'TMDB error (${e.response?.statusCode ?? 'unknown'})',
          statusCode: e.response?.statusCode);
    }
  }
}
