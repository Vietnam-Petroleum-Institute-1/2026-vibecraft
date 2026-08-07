import cors from 'cors';
import express from 'express';
import helmet from 'helmet';

import { errorMiddleware } from './core/middleware/error.middleware';
import { requestIdMiddleware } from './core/middleware/request-id.middleware';
import { healthRouter } from './modules/health/health.routes';

export const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(requestIdMiddleware);

app.use('/health', healthRouter);

// Error middleware MUST be registered last.
app.use(errorMiddleware);
