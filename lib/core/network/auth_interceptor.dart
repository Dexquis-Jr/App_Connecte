import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../constants/api_constants.dart';

/// Injects the bearer token on every outgoing request and transparently
/// retries once after refreshing the token on a 401.
///
/// Refreshes access tokens through the NestJS backend without intercepting the
/// refresh request itself, which avoids an infinite retry loop.
class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorage;
  final Dio
      _refreshDio; // separate Dio instance, no interceptor, avoids recursion
  final Dio? _retryDio;
  static const _retryKey = 'auth_retry_done';

  Future<String?>? _refreshing;

  AuthInterceptor({required this.secureStorage, Dio? refreshDio, Dio? retryDio})
      : _refreshDio =
            refreshDio ?? Dio(BaseOptions(baseUrl: ApiConstants.authBaseUrl)),
        _retryDio = retryDio;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isAuthEndpoint = err.requestOptions.path.contains('/auth/');

    final alreadyRetried = err.requestOptions.extra[_retryKey] == true;

    if (isUnauthorized && !isAuthEndpoint && !alreadyRetried) {
      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          final retryOptions = err.requestOptions;
          retryOptions.extra[_retryKey] = true;
          retryOptions.headers['Authorization'] = 'Bearer $newToken';
          final cloneReq = await (_retryDio ?? _refreshDio).fetch(retryOptions);
          return handler.resolve(cloneReq);
        }
      } catch (_) {
        // fall through to propagate the original error / force logout
      }
    }
    handler.next(err);
  }

  /// Single-flight refresh: if a refresh is already in progress, callers
  /// await the same future instead of firing duplicate refresh requests.
  Future<String?> _refreshToken() {
    final currentRefresh = _refreshing;
    if (currentRefresh != null) return currentRefresh;

    final refresh = _refreshTokenOnce();
    _refreshing = refresh;
    return refresh.whenComplete(() {
      if (identical(_refreshing, refresh)) _refreshing = null;
    });
  }

  Future<String?> _refreshTokenOnce() async {
    final refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken == null) return null;

    final tokens = await _performRefresh(refreshToken);
    if (tokens == null) return null;

    await secureStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens.accessToken;
  }

  Future<_TokenPair?> _performRefresh(String refreshToken) async {
    final response = await _refreshDio
        .post(ApiConstants.refreshPath, data: {'refreshToken': refreshToken});
    final accessToken = response.data['token'] as String?;
    final nextRefreshToken = response.data['refreshToken'] as String?;
    if (accessToken == null || nextRefreshToken == null) return null;
    return _TokenPair(accessToken, nextRefreshToken);
  }
}

class _TokenPair {
  final String accessToken;
  final String refreshToken;

  const _TokenPair(this.accessToken, this.refreshToken);
}
