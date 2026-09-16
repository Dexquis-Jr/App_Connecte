import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<RepositoryResult<User>> login({required String email, required String password});
  Future<RepositoryResult<User>> register({required String email, required String password});
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<User?> currentUser();
}
