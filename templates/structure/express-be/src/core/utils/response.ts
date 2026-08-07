import { Response } from 'express';

// Standardized success/error envelope so every route returns the same shape.
export function sendSuccess<T>(res: Response, data: T, status = 200): void {
  res.status(status).json({ success: true, data, meta: null, error: null });
}

export function sendError(res: Response, message: string, status = 500): void {
  res.status(status).json({ success: false, data: null, meta: null, error: { message } });
}
