import { useCallback, useEffect, useState } from 'react';

import { healthService } from '../services/health.service';
import { HealthResponse } from '../types/api.types';

export function useHealth() {
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  const check = useCallback(() => {
    setError(null);
    healthService
      .check()
      .then(setHealth)
      .catch((err: Error) => setError(err.message));
  }, []);

  useEffect(check, [check]);

  return { health, error, check };
}
