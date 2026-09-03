import { Controller, Get } from '@nestjs/common';

import { HealthSnapshot } from './health.repository';
import { HealthService } from './health.service';

@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  check(): HealthSnapshot {
    return this.healthService.check();
  }
}
