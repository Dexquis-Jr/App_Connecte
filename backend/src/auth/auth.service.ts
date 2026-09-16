import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import Database from 'better-sqlite3';
import * as bcrypt from 'bcrypt';
import { randomUUID } from 'node:crypto';
import { CredentialsDto } from './auth.dto';

type UserRecord = { id: string; email: string; password_hash: string };

@Injectable()
export class AuthService {
    private readonly database: Database.Database;

    constructor(private readonly jwtService: JwtService) {
        this.database = new Database(process.env.DATABASE_PATH ?? 'data.sqlite');
        this.database.pragma('journal_mode = WAL');
        this.database.exec(`
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
      CREATE TABLE IF NOT EXISTS revoked_tokens (
        token_id TEXT PRIMARY KEY,
        expires_at INTEGER NOT NULL
      );
    `);
    }

    async register(credentials: CredentialsDto) {
        const email = credentials.email.trim().toLowerCase();
        const existing = this.database.prepare('SELECT id FROM users WHERE email = ?').get(email);
        if (existing) throw new ConflictException('Un compte existe déjà avec cet email.');

        const user = { id: randomUUID(), email };
        const passwordHash = await bcrypt.hash(credentials.password, 12);
        this.database
            .prepare('INSERT INTO users (id, email, password_hash) VALUES (?, ?, ?)')
            .run(user.id, user.email, passwordHash);
        return this.issueTokens(user);
    }

    async login(credentials: CredentialsDto) {
        const email = credentials.email.trim().toLowerCase();
        const user = this.database
            .prepare('SELECT id, email, password_hash FROM users WHERE email = ?')
            .get(email) as UserRecord | undefined;
        if (!user || !(await bcrypt.compare(credentials.password, user.password_hash))) {
            throw new UnauthorizedException('Email ou mot de passe incorrect.');
        }
        return this.issueTokens({ id: user.id, email: user.email });
    }

    refresh(refreshToken: string) {
        try {
            const payload = this.jwtService.verify<{ sub: string; email: string; type: string; jti: string }>(
                refreshToken,
            );
            if (payload.type !== 'refresh' || this.isRevoked(payload.jti)) {
                throw new UnauthorizedException('Refresh token invalide.');
            }
            return this.issueTokens({ id: payload.sub, email: payload.email });
        } catch {
            throw new UnauthorizedException('Refresh token invalide ou expiré.');
        }
    }

    logout(token: string) {
        try {
            const payload = this.jwtService.verify<{ jti: string; exp: number }>(token);
            this.database
                .prepare('INSERT OR REPLACE INTO revoked_tokens (token_id, expires_at) VALUES (?, ?)')
                .run(payload.jti, payload.exp);
            return { message: 'Déconnexion réussie.' };
        } catch {
            throw new UnauthorizedException('Token invalide.');
        }
    }

    private issueTokens(user: { id: string; email: string }) {
        const accessToken = this.jwtService.sign(
            { email: user.email, type: 'access' },
            { subject: user.id, expiresIn: '15m', jwtid: randomUUID() },
        );
        const refreshToken = this.jwtService.sign(
            { email: user.email, type: 'refresh' },
            { subject: user.id, expiresIn: '30d', jwtid: randomUUID() },
        );
        return {
            token: accessToken,
            refreshToken,
            user: { id: user.id, email: user.email },
        };
    }

    private isRevoked(tokenId: string) {
        const row = this.database
            .prepare('SELECT token_id FROM revoked_tokens WHERE token_id = ? AND expires_at > ?')
            .get(tokenId, Math.floor(Date.now() / 1000));
        return Boolean(row);
    }
}