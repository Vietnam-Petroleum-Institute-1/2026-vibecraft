import { Test } from '@nestjs/testing';

import { HealthService } from '../../../src/modules/health/health.service';
import { HealthRepository } from '../../../src/modules/health/health.repository';

describe('HealthService', () => {
  let service: HealthService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [HealthService, HealthRepository],
    }).compile();

    service = module.get(HealthService);
  });

  it('returns status ok', () => {
    expect(service.check().status).toBe('ok');
  });

  it('returns a non-negative uptime', () => {
    expect(service.check().uptimeSeconds).toBeGreaterThanOrEqual(0);
  });
});
