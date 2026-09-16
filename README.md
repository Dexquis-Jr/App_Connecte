# Application Flutter Movie App

Client mobile, desktop et web de Movie App. L'application utilise :

- le backend NestJS local pour l'inscription, la connexion, le refresh et le logout;
- TMDB pour les données de films;
- Hive pour le cache hors ligne;
- `flutter_secure_storage` pour les tokens;
- Provider et ChangeNotifier pour l'état de l'application.

## Prérequis

- Flutter 3.19 ou supérieur.
- Dart 3.3 ou supérieur.
- Node.js 20 ou supérieur pour lancer le backend.
- Une clé API TMDB : [https://www.themoviedb.org/settings/api](https://www.themoviedb.org/settings/api).

## Configuration

### Clé TMDB

Ne commitez pas la clé TMDB. Fournissez-la au lancement avec `--dart-define` :

```bash
flutter run --dart-define=TMDB_API_KEY=VOTRE_CLE_TMDB
```

La clé est utilisée par `MoviesRemoteDataSourceImpl` pour appeler TMDB. Les résultats sont demandés en français avec `language=fr-FR`.

### Adresse du backend

L'adresse est définie dans `lib/core/constants/api_constants.dart` :

- Web, Linux, macOS et Windows : `http://localhost:3000`.
- Émulateur Android : `http://10.0.2.2:3000`.
- Téléphone physique : remplacez l'adresse par l'IP locale de votre ordinateur.

Le backend doit être lancé avant de tester l'authentification.

## Installation

```bash
flutter pub get
```

## Lancement complet

Terminal 1, depuis `backend/` :

```bash
npm install
cp .env.example .env
npm run start:dev
```

Terminal 2, depuis `movie_app/` :

```bash
flutter run --dart-define=TMDB_API_KEY=VOTRE_CLE_TMDB
```

## Parcours utilisateur

1. Lancez l'application.
2. Créez un compte avec une adresse email et un mot de passe d'au moins 8 caractères.
3. L'application ouvre automatiquement l'écran des films après l'inscription.
4. Fermez puis relancez l'application : la session enregistrée est restaurée.
5. Consultez les films populaires, les mieux notés ou recherchez un film.
6. Utilisez le bouton de déconnexion pour révoquer la session et revenir au login.

## Fonctionnement de l'authentification

`AuthProvider` orchestre les use cases `LoginUseCase`, `RegisterUseCase` et `LogoutUseCase`.

`AuthRepositoryImpl` :

- appelle `/auth/login` ou `/auth/register`;
- sauvegarde l'access token, le refresh token et l'utilisateur;
- appelle `/auth/logout` avant de supprimer les données locales;
- restaure l'utilisateur depuis l'email stocké.

`AuthInterceptor` ajoute automatiquement `Authorization: Bearer <token>` aux requêtes et appelle `/auth/refresh` lorsqu'un service renvoie `401`.

## Fonctionnement des films

Les écrans disponibles sont :

- Popular Movies;
- Top Rated;
- Search;
- Movie Detail.

`MoviesRepositoryImpl` utilise TMDB lorsque le réseau est disponible, puis sauvegarde les résultats dans Hive. En cas de coupure réseau ou d'erreur serveur, l'application utilise les données du cache lorsque c'est possible.

## Architecture

```text
lib/
├── app.dart                    # MaterialApp et AuthGate
├── main.dart                   # initialisation Hive et injection
├── core/
│   ├── constants/              # URLs backend, URLs TMDB et clé API
│   ├── di/                     # composition des dépendances
│   ├── error/                  # exceptions et failures
│   ├── network/                # Dio, réseau et interceptor JWT
│   └── storage/                # Hive et secure storage
└── features/
    ├── auth/
    │   ├── data/               # datasource, modèles et repository
    │   ├── domain/             # entité User, contrats et use cases
    │   └── presentation/       # écrans et AuthProvider
    └── movies/
        ├── data/               # datasource TMDB, cache et repository
        ├── domain/             # entité Movie, contrats et use cases
        └── presentation/       # providers, écrans et widgets
```

La direction des dépendances est `presentation → domain ← data`.

## Tests

Tous les tests Flutter :

```bash
flutter test
```

Les tests couvrent notamment :

- la connexion et la persistance des tokens;
- les erreurs de validation et de réseau;
- la déconnexion et le nettoyage du stockage;
- l'affichage de l'écran de connexion;
- la transition login/logout;
- le cache et le mode hors ligne des films;
- les use cases des films.

## Dépannage

### Le login ne fonctionne pas

Vérifiez que le backend est lancé sur le bon port et que `authBaseUrl` correspond à votre plateforme.

### Les films ne se chargent pas

Vérifiez la clé dans `lib/core/constants/tmdb_key.dart`, la connexion réseau et les logs TMDB.

### Android Emulator

Utilisez `10.0.2.2` pour joindre le backend local de votre ordinateur. `localhost` désigne l'émulateur lui-même.

### Téléphone physique

Le téléphone et l'ordinateur doivent être sur le même réseau. Utilisez l'adresse IP locale de l'ordinateur et autorisez le port `3000` dans le pare-feu.

## Validation

```bash
flutter analyze
flutter test
```
