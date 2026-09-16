# Backend NestJS de Movie App

API REST responsable de l'authentification de l'application Flutter.

## Fonctionnalités

- Inscription avec email et mot de passe.
- Connexion et émission de tokens JWT.
- Refresh token valable 30 jours.
- Révocation du token d'accès lors de la déconnexion.
- Mots de passe hachés avec bcrypt.
- Utilisateurs stockés dans SQLite.
- Validation automatique des requêtes.
- CORS activé pour le développement Flutter Web.

## Prérequis

- Node.js 20 ou supérieur.
- npm.

## Installation

```bash
cd backend
npm install
cp .env.example .env
```

Configuration `.env` :

```env
PORT=3000
JWT_SECRET=remplacez-par-un-secret-long-et-aleatoire
DATABASE_PATH=data.sqlite
```

- `PORT` définit le port HTTP.
- `JWT_SECRET` signe les tokens JWT.
- `DATABASE_PATH` indique où créer la base SQLite.

## Lancement

Développement avec rechargement automatique :

```bash
npm run start:dev
```

Développement sans watch :

```bash
npm run start
```

Production :

```bash
npm run build
npm run start:prod
```

Par défaut, l'API est disponible sur `http://localhost:3000`.

## Endpoints

### `POST /auth/register`

Crée un utilisateur et renvoie immédiatement une session.

```json
{
  "email": "utilisateur@example.com",
  "password": "motdepasse123"
}
```

Le mot de passe doit contenir au moins 8 caractères.

### `POST /auth/login`

Authentifie un utilisateur existant.

```json
{
  "email": "utilisateur@example.com",
  "password": "motdepasse123"
}
```

Réponse de session :

```json
{
  "token": "jwt-access-token",
  "refreshToken": "jwt-refresh-token",
  "user": {
    "id": "uuid",
    "email": "utilisateur@example.com"
  }
}
```

### `POST /auth/refresh`

Crée une nouvelle paire de tokens à partir du refresh token.

```json
{
  "refreshToken": "jwt-refresh-token"
}
```

### `POST /auth/logout`

Révoque le token d'accès courant.

```http
Authorization: Bearer jwt-access-token
```

Réponse :

```json
{
  "message": "Déconnexion réussie."
}
```

## Structure du backend

```text
backend/src/
├── auth/
│   ├── auth.controller.ts # routes HTTP /auth/*
│   ├── auth.dto.ts        # validation des payloads
│   ├── auth.module.ts     # module NestJS
│   └── auth.service.ts    # SQLite, bcrypt et JWT
├── app.module.ts
└── main.ts                # CORS et ValidationPipe
```

Les tables SQLite sont créées automatiquement au démarrage :

- `users` : identifiant, email, hash du mot de passe et date de création.
- `revoked_tokens` : identifiants JWT révoqués et date d'expiration.

## Tests

Compiler le backend :

```bash
npm run build
```

Lancer les tests unitaires :

```bash
npm test -- --runInBand
```

Lancer les tests en mode watch :

```bash
npm run test:watch
```

Lancer les tests e2e :

```bash
npm run test:e2e
```

## Sécurité

- Ne commitez jamais `.env` ni `data.sqlite`.
- Utilisez un vrai secret JWT en production.
- Activez HTTPS derrière un reverse proxy.
- Remplacez SQLite par une base serveur pour un déploiement multi-instance.
- Restreignez CORS aux domaines autorisés avant la mise en ligne.
