import { checkHealth } from '../../../src/modules/health/health.service';

describe('checkHealth', () => {
  it('returns status ok', async () => {
    expect((await checkHealth()).status).toBe('ok');
  });

  it('returns a non-negative uptime', async () => {
    expect((await checkHealth()).uptimeSeconds).toBeGreaterThanOrEqual(0);
  });
});
