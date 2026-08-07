import { Injectable } from '@nestjs/common';

import { HealthRepository, HealthSnapshot } from './health.repository';

@Injectable()
export class HealthService {
  constructor(private readonly healthRepository: HealthRepository) {}

  check(): HealthSnapshot {
    return this.healthRepository.getSnapshot();
  }
}
