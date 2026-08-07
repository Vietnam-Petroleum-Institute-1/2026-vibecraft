import { onMounted, ref } from 'vue';

import { healthService } from '../services/health.service';
import { HealthResponse } from '../types/api.types';

export function useHealth() {
  const health = ref<HealthResponse | null>(null);
  const error = ref<string | null>(null);

  const check = () => {
    error.value = null;
    healthService
      .check()
      .then((result) => (health.value = result))
      .catch((err: Error) => (error.value = err.message));
  };

  onMounted(check);

  return { health, error, check };
}
