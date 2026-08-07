import { Injectable } from '@nestjs/common';
import { ConfigService as NestConfigService } from '@nestjs/config';

// Thin, typed wrapper around @nestjs/config so the rest of the app never
// reads process.env directly (see AGENTS.md "Security Rules" — secrets only
// via environment variables, read from one place).
@Injectable()
export class AppConfigService {
  constructor(private readonly config: NestConfigService) {}

  get port(): number {
    return Number(this.config.get('PORT', '3000'));
  }

  get databaseUrl(): string | undefined {
    return this.config.get<string>('DATABASE_URL');
  }

  get jwtAccessSecret(): string {
    return this.config.getOrThrow<string>('JWT_ACCESS_SECRET');
  }
}
