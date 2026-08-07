import { app } from './app';
import { config } from './core/config';
import { logger } from './core/utils/logger';

const server = app.listen(config.port, () => {
  logger.info(`Listening on port ${config.port}`);
});

function shutdown(signal: string): void {
  logger.info(`${signal} received, shutting down gracefully`);
  server.close(() => process.exit(0));
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
