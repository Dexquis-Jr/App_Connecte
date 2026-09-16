import 'package:flutter/material.dart';
import '../providers/movies_provider.dart';
import 'movie_card.dart';

/// Shared list body for the popular / top-rated / search screens: handles
/// loading, error (with a network-friendly icon/message), the "offline —
/// showing cached data" banner, and the actual list rendering.
class MovieListBody extends StatelessWidget {
  final MovieListState state;
  final String emptyMessage;

  const MovieListBody({super.key, required this.state, this.emptyMessage = 'Nothing here yet'});

  @override
  Widget build(BuildContext context) {
    if (state.state == LoadState.loading && state.movies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.state == LoadState.error && state.movies.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.wifi_off_rounded, size: 48),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(state.errorMessage ?? 'Something went wrong', textAlign: TextAlign.center),
          ),
        ],
      );
    }
    if (state.state == LoadState.loaded && state.movies.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return Column(
      children: [
        if (state.isFromCache)
          Container(
            width: double.infinity,
            color: Colors.amber.shade100,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: const Row(
              children: [
                Icon(Icons.cloud_off, size: 16),
                SizedBox(width: 8),
                Text('Offline — showing cached data', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: state.movies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => MovieCard(movie: state.movies[i]),
          ),
        ),
      ],
    );
  }
}
