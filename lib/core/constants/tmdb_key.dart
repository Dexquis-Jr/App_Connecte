// Provide the key at build/run time with:
// flutter run --dart-define=TMDB_API_KEY=your_key
const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');
