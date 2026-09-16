import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<RepositoryResult<User>> call({required String email, required String password}) {
    return repository.register(email: email, password: password);
  }
}
