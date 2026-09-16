import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/movies_provider.dart';
import '../widgets/movie_list_body.dart';
import 'top_rated_screen.dart';
import 'search_screen.dart';

class PopularMoviesScreen extends StatefulWidget {
  const PopularMoviesScreen({super.key});

  @override
  State<PopularMoviesScreen> createState() => _PopularMoviesScreenState();
}

class _PopularMoviesScreenState extends State<PopularMoviesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoviesProvider>().loadPopular();
    });
  }

  @override
  Widget build(BuildContext context) {
    final moviesState = context.watch<MoviesProvider>().popular;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.star_outline),
            tooltip: 'Top Rated',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TopRatedScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<MoviesProvider>().loadPopular(),
        child: MovieListBody(state: moviesState),
      ),
    );
  }
}
