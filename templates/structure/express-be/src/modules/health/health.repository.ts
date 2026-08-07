export interface HealthSnapshot {
  status: 'ok';
  uptimeSeconds: number;
}

// ONLY layer allowed to query the database — see AGENTS.md "Architecture
// Rules". Health has no persisted state yet, so this reads from the process
// instead; once you have real tables, swap this for a real
// `pool.query('SELECT 1')` check (see src/core/database.ts).
export function getHealthSnapshot(): HealthSnapshot {
  return { status: 'ok', uptimeSeconds: Math.floor(process.uptime()) };
}
