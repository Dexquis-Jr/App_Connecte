import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

/// Factory for the two Dio instances the app needs:
/// - [authDio]: talks to the auth backend, no token injection needed for
///   login/register but does attach it for any future authenticated
///   auth-service calls (e.g. GET /me).
/// - [dataDio]: talks to TMDB, uses [AuthInterceptor] to attach *our own*
///   backend's token (kept separate from TMDB's own api_key query param)
///   to demonstrate the interceptor pattern requested by the assignment.
class ApiClient {
  final SecureStorageService secureStorage;
  ApiClient(this.secureStorage);

  late final Dio authDio =
      _build(ApiConstants.authBaseUrl, withAuthInterceptor: true);
  late final Dio dataDio =
      _build(ApiConstants.tmdbBaseUrl, withAuthInterceptor: true);

  Dio _build(String baseUrl, {required bool withAuthInterceptor}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (withAuthInterceptor) {
      dio.interceptors.add(
        AuthInterceptor(secureStorage: secureStorage, retryDio: dio),
      );
    }

    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false, logPrint: (_) {}),
    );

    return dio;
  }
}
