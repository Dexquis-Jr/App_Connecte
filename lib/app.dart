import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injector.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/movies/presentation/providers/movies_provider.dart';
import 'features/movies/presentation/screens/popular_movies_screen.dart';

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Injector.buildAuthProvider()),
        ChangeNotifierProvider(create: (_) => Injector.buildMoviesProvider()),
      ],
      child: MaterialApp(
        title: 'Movie App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D253F)),
          useMaterial3: true,
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

/// Watches [AuthProvider.status] and swaps between the login flow and the
/// authenticated app shell — a simple router-free gate suitable for an app
/// this size.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;
    switch (status) {
      case AuthStatus.unknown:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        return const PopularMoviesScreen();
    }
  }
}
