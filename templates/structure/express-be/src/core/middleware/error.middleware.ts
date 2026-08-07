import { NextFunction, Request, Response } from 'express';

import { logger } from '../utils/logger';
import { sendError } from '../utils/response';

// Global error handler — MUST be registered last, after all routes.
// RFC 7807-style detail, see AGENTS.md "Code Style Rules".
export function errorMiddleware(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction,
): void {
  const requestId = req.headers['x-request-id'];
  logger.error({ err, requestId, path: req.path }, 'Unhandled error');
  sendError(res, 'Internal server error', 500);
}
