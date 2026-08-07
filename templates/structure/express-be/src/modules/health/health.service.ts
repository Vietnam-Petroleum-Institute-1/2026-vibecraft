import { getHealthSnapshot, HealthSnapshot } from './health.repository';

// async because a real DB ping (see modules/health/health.repository.ts) will
// need to be awaited once one is added — kept consistent with every other
// service in the app, which are async.
// eslint-disable-next-line @typescript-eslint/require-await
export async function checkHealth(): Promise<HealthSnapshot> {
  return getHealthSnapshot();
}
