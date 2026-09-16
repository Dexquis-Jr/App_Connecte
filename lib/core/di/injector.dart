import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../storage/secure_storage_service.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/movies/data/datasources/movies_local_datasource.dart';
import '../../features/movies/data/datasources/movies_remote_datasource.dart';
import '../../features/movies/data/repositories/movies_repository_impl.dart';
import '../../features/movies/domain/repositories/movies_repository.dart';
import '../../features/movies/domain/usecases/get_popular_movies.dart';
import '../../features/movies/domain/usecases/get_top_rated_movies.dart';
import '../../features/movies/domain/usecases/search_movies.dart';
import '../../features/movies/presentation/providers/movies_provider.dart';

/// Minimal, hand-rolled composition root (no code-gen DI framework needed
/// for a project this size). Wires data sources -> repositories -> use
/// cases -> presentation providers, following the dependency-inversion
/// direction required by Clean Architecture (inner layers know nothing
/// about outer ones).
class Injector {
  static late SecureStorageService secureStorage;
  static late ApiClient apiClient;
  static late NetworkInfo networkInfo;

  static late AuthRepository authRepository;
  static late MoviesRepository moviesRepository;

  static void setup() {
    secureStorage = SecureStorageService();
    apiClient = ApiClient(secureStorage);
    networkInfo = NetworkInfoImpl(Connectivity());

    authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(apiClient.authDio),
      secureStorage: secureStorage,
    );

    moviesRepository = MoviesRepositoryImpl(
      remoteDataSource: MoviesRemoteDataSourceImpl(apiClient.dataDio),
      localDataSource: MoviesLocalDataSourceImpl(),
      networkInfo: networkInfo,
    );
  }

  static AuthProvider buildAuthProvider() {
    return AuthProvider(
      loginUseCase: LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      isLoggedInCheck: authRepository.isLoggedIn,
      currentUserFetch: authRepository.currentUser,
    );
  }

  static MoviesProvider buildMoviesProvider() {
    return MoviesProvider(
      getPopularMovies: GetPopularMovies(moviesRepository),
      getTopRatedMovies: GetTopRatedMovies(moviesRepository),
      searchMoviesUseCase: SearchMovies(moviesRepository),
    );
  }
}
