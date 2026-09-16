import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  // ---- Auth backend -------------------------------------------------
  // Local NestJS backend. For a deployed API, replace this with its HTTPS URL.
  static String get authBaseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android)
      return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  static const String loginPath = '/auth/login';
  static const String registerPath = '/auth/register';
  static const String logoutPath = '/auth/logout';
  static const String refreshPath = '/auth/refresh';

  // ---- Movies data backend (TMDB) -----------------------------------
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  static const String popularMoviesPath = '/movie/popular';
  static const String topRatedMoviesPath = '/movie/top_rated';
  static const String searchMoviesPath = '/search/movie';
  static const String movieDetailPath = '/movie';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
