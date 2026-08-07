import { Router } from 'express';

import { asyncHandler } from '../../core/utils/async-handler';
import { sendSuccess } from '../../core/utils/response';

import { checkHealth } from './health.service';

export const healthRouter = Router();

// Router ONLY: receive request, delegate to service, return response — see
// AGENTS.md "Architecture Rules". No business logic, no repository calls here.
healthRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    sendSuccess(res, await checkHealth());
  }),
);
