import { Pool } from 'pg';

import { config } from './config';

// Plain `pg` Pool instead of an ORM — no code-generation step needed before
// the very first `pnpm install` (Prisma's client generator refuses to run
// with zero models defined, which broke a fresh project's first install —
// see plans/06-folder-structure-scaffolds.md). Swap for TypeORM/Prisma/
// Drizzle once you have real tables and want migrations.
export const pool = new Pool({ connectionString: config.databaseUrl });
