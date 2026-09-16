import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movies_provider.dart';
import '../widgets/movie_list_body.dart';

class TopRatedScreen extends StatefulWidget {
  const TopRatedScreen({super.key});

  @override
  State<TopRatedScreen> createState() => _TopRatedScreenState();
}

class _TopRatedScreenState extends State<TopRatedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoviesProvider>().loadTopRated();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MoviesProvider>().topRated;
    return Scaffold(
      appBar: AppBar(title: const Text('Top Rated')),
      body: RefreshIndicator(
        onRefresh: () => context.read<MoviesProvider>().loadTopRated(),
        child: MovieListBody(state: state),
      ),
    );
  }
}
