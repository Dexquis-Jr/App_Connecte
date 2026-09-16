import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/storage/secure_storage_service.dart';
import 'package:movie_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:movie_app/features/auth/data/models/auth_response_model.dart';
import 'package:movie_app/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late MockSecureStorageService secureStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    secureStorage = MockSecureStorageService();
    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      secureStorage: secureStorage,
    );

    when(() => secureStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
    when(() => secureStorage.saveUserEmail(any())).thenAnswer((_) async {});
    when(() => secureStorage.clear()).thenAnswer((_) async {});
    when(() => secureStorage.getAccessToken()).thenAnswer((_) async => null);
  });

  const email = 'eve.holt@reqres.in';
  const password = 'cityslicka';

  group('login', () {
    test(
        'returns a successful RepositoryResult<User> and persists tokens on success',
        () async {
      when(() => remoteDataSource.login(email: email, password: password))
          .thenAnswer((_) async => AuthResponseModel(token: 'fake-jwt-token'));

      final result = await repository.login(email: email, password: password);

      expect(result.isSuccess, isTrue);
      expect(result.data?.email, email);
      verify(() => secureStorage.saveTokens(
          accessToken: 'fake-jwt-token',
          refreshToken: 'fake-jwt-token')).called(1);
      verify(() => secureStorage.saveUserEmail(email)).called(1);
    });

    test('returns AuthFailure when credentials are invalid', () async {
      when(() => remoteDataSource.login(email: email, password: password))
          .thenThrow(ValidationException('user not found'));

      final result = await repository.login(email: email, password: password);

      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<AuthFailure>());
      expect(result.failure?.message, 'user not found');
      verifyNever(() => secureStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ));
    });

    test('returns NetworkFailure when there is no connectivity', () async {
      when(() => remoteDataSource.login(email: email, password: password))
          .thenThrow(NetworkException());

      final result = await repository.login(email: email, password: password);

      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<NetworkFailure>());
    });
  });

  group('logout', () {
    test('clears secure storage', () async {
      await repository.logout();
      verify(() => secureStorage.clear()).called(1);
    });
  });
}
