import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final Future<bool> Function() isLoggedInCheck;
  final Future<User?> Function() currentUserFetch;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.isLoggedInCheck,
    required this.currentUserFetch,
  }) {
    _checkSession();
  }

  AuthStatus status = AuthStatus.unknown;
  User? user;
  String? errorMessage;
  bool isLoading = false;

  Future<void> _checkSession() async {
    final loggedIn = await isLoggedInCheck();
    if (loggedIn) {
      user = await currentUserFetch();
      status = AuthStatus.authenticated;
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await loginUseCase(email: email, password: password);
      if (result.isSuccess) {
        user = result.data;
        status = AuthStatus.authenticated;
        return true;
      }
      errorMessage = result.failure?.message ?? 'Login failed';
      return false;
    } catch (error) {
      errorMessage = 'Login failed: $error';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await registerUseCase(email: email, password: password);
      if (result.isSuccess) {
        user = result.data;
        status = AuthStatus.authenticated;
        return true;
      }
      errorMessage = result.failure?.message ?? 'Registration failed';
      return false;
    } catch (error) {
      errorMessage = 'Registration failed: $error';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await logoutUseCase();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
