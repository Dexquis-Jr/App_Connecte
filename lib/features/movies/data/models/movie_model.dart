import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.voteAverage,
    required super.releaseDate,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? 'Untitled') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      voteAverage: ((json['vote_average'] ?? 0) as num).toDouble(),
      releaseDate: (json['release_date'] ?? '') as String,
    );
  }

  /// Used both for TMDB JSON and for round-tripping through the Hive cache,
  /// since Hive stores plain Map<String, dynamic> without needing a
  /// generated TypeAdapter.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'overview': overview,
        'poster_path': posterPath,
        'vote_average': voteAverage,
        'release_date': releaseDate,
      };
}
