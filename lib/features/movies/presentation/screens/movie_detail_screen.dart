import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/movie.dart';

/// This screen renders from the [Movie] entity already loaded by the list
/// screens (popular/top-rated/search), so it works offline for anything
/// the user has already seen — no extra network round trip needed.
class MovieDetailScreen extends StatelessWidget {
  final Movie movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: movie.posterPath != null
                  ? Image.network(
                      '${ApiConstants.tmdbImageBaseUrl}${movie.posterPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.black26),
                    )
                  : Container(color: Colors.black26),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text('${movie.voteAverage.toStringAsFixed(1)} / 10'),
                      const SizedBox(width: 16),
                      Text(movie.releaseDate.isNotEmpty ? movie.releaseDate : 'Unknown release date'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Overview', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview.isNotEmpty ? movie.overview : 'No overview available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
