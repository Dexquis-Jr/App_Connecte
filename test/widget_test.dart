// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:movie_app/features/auth/presentation/screens/login_screen.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/auth/domain/entities/user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:movie_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:movie_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:movie_app/features/auth/presentation/providers/auth_provider.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<RepositoryResult<User>> login(
      {required String email, required String password}) async {
    return RepositoryResult.success(User(id: 'test-user', email: email));
  }

  @override
  Future<RepositoryResult<User>> register(
      {required String email, required String password}) async {
    return RepositoryResult.success(User(id: 'test-user', email: email));
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<User?> currentUser() async => null;
}

void main() {
  testWidgets('login screen can be constructed', (WidgetTester tester) async {
    final repository = _FakeAuthRepository();
    final authProvider = _buildAuthProvider(repository);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authProvider,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Bienvenue dans Movie App'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  test('login and logout update the authentication state', () async {
    final repository = _FakeAuthRepository();
    final authProvider = _buildAuthProvider(repository);

    expect(await authProvider.login('user@example.com', 'password'), isTrue);
    expect(authProvider.status, AuthStatus.authenticated);
    expect(authProvider.user?.email, 'user@example.com');

    await authProvider.logout();

    expect(authProvider.status, AuthStatus.unauthenticated);
    expect(authProvider.user, isNull);
  });
}

AuthProvider _buildAuthProvider(AuthRepository repository) {
  return AuthProvider(
    loginUseCase: LoginUseCase(repository),
    registerUseCase: RegisterUseCase(repository),
    logoutUseCase: LogoutUseCase(repository),
    isLoggedInCheck: repository.isLoggedIn,
    currentUserFetch: repository.currentUser,
  );
}
