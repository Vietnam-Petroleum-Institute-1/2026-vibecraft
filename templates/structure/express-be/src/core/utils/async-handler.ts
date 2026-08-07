import { NextFunction, Request, RequestHandler, Response } from 'express';

// Wraps an async route handler so a rejected Promise is forwarded to
// Express's error middleware instead of crashing the process unhandled.
export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<void>,
): RequestHandler {
  return (req, res, next) => {
    fn(req, res, next).catch(next);
  };
}
