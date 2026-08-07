import pino from 'pino';

// Single logger instance for the whole app — see AGENTS.md "Code Style
// Rules" (always log errors with context). Import this everywhere instead
// of console.log/console.error.
//
// Plain JSON output by default (no extra dependency required). If you want
// pretty-printed logs in development, add `pino-pretty` as a devDependency
// and set `transport: { target: 'pino-pretty' }` here.
export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
});
