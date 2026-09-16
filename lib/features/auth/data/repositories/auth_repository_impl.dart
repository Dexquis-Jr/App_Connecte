import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl(
      {required this.remoteDataSource, required this.secureStorage});

  @override
  Future<RepositoryResult<User>> login(
      {required String email, required String password}) async {
    try {
      final authResponse =
          await remoteDataSource.login(email: email, password: password);
      final user = authResponse.user ?? UserModel.fromEmail(email);
      await secureStorage.saveTokens(
        accessToken: authResponse.token,
        refreshToken: authResponse.refreshToken ?? authResponse.token,
      );
      await secureStorage.saveUserEmail(email);
      return RepositoryResult.success(user);
    } on NetworkException catch (e) {
      return RepositoryResult.error(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return RepositoryResult.error(AuthFailure(e.message));
    } on ServerException catch (e) {
      return RepositoryResult.error(ServerFailure(e.message));
    } catch (e) {
      return RepositoryResult.error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<RepositoryResult<User>> register(
      {required String email, required String password}) async {
    try {
      final authResponse =
          await remoteDataSource.register(email: email, password: password);
      final user = authResponse.user ?? UserModel.fromEmail(email);
      await secureStorage.saveTokens(
        accessToken: authResponse.token,
        refreshToken: authResponse.refreshToken ?? authResponse.token,
      );
      await secureStorage.saveUserEmail(email);
      return RepositoryResult.success(user);
    } on NetworkException catch (e) {
      return RepositoryResult.error(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return RepositoryResult.error(AuthFailure(e.message));
    } on ServerException catch (e) {
      return RepositoryResult.error(ServerFailure(e.message));
    } catch (e) {
      return RepositoryResult.error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<void> logout() async {
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      try {
        await remoteDataSource.logout(token: token);
      } catch (_) {
        // Always clear local credentials, even if the server is unreachable.
      }
    }
    await secureStorage.clear();
  }

  @override
  Future<bool> isLoggedIn() => secureStorage.hasValidSession();

  @override
  Future<User?> currentUser() async {
    final email = await secureStorage.getUserEmail();
    if (email == null) return null;
    return UserModel.fromEmail(email);
  }
}
