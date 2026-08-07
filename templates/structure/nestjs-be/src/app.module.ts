import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { HealthModule } from './modules/health/health.module';

// NOTE: TypeOrmModule is intentionally NOT wired here yet — doing so would
// require a live database at first boot, which breaks `pnpm start:dev` right
// after `init.sh` runs (before the user has set up Postgres). Add it once you
// have a real DATABASE_URL:
//
//   TypeOrmModule.forRoot({ type: 'postgres', url: process.env.DATABASE_URL, autoLoadEntities: true })
//
// `entities/base.entity.ts` and the per-module repository pattern (e.g.
// `modules/health/health.repository.ts`) are ready to use as-is once you do.
@Module({
  imports: [ConfigModule.forRoot({ isGlobal: true }), HealthModule],
})
export class AppModule {}
