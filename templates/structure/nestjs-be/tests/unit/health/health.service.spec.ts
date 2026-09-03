import { Test } from '@nestjs/testing';

import { HealthRepository } from '../../../src/modules/health/health.repository';
import { HealthService } from '../../../src/modules/health/health.service';

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
