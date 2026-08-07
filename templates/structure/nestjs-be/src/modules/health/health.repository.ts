import { Injectable } from '@nestjs/common';

export interface HealthSnapshot {
  status: 'ok';
  uptimeSeconds: number;
}

// ONLY layer allowed to query a data source — see AGENTS.md "Architecture
// Rules". Health has no persisted state yet, so this reads from the process
// instead of a database; once `AppModule` wires TypeOrmModule (see the note
// there), swap this for a real `DataSource.query('SELECT 1')` check.
@Injectable()
export class HealthRepository {
  getSnapshot(): HealthSnapshot {
    return { status: 'ok', uptimeSeconds: Math.floor(process.uptime()) };
  }
}
