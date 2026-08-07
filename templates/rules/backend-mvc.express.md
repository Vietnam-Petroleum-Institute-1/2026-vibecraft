---
title: Backend Structure — Express
slug: backend-mvc
applies_to: backend
cursor_globs: backend/**/*.ts
copilot_apply_to: backend/**/*.ts
cline_globs: backend/**/*.ts
---

### Tech stack (Backend)
- **Framework**: Express 4 · **Language**: TypeScript 5.x
- **ORM/DB**: Prisma or Sequelize + PostgreSQL (confirm with the project's `package.json`)
- **Validation**: Zod (preferred) or Joi
- **Auth**: `jsonwebtoken` + custom middleware
- **Package manager**: pnpm

### Module structure

```
modules/[feature]/
  ├── [feature].routes.ts        ← express.Router() — Controller in MVC, ONLY route wiring
  ├── [feature].service.ts       ← business logic class
  ├── [feature].repository.ts    ← ONLY layer allowed to query the DB
  ├── [feature].validator.ts     ← Zod/Joi schemas
  └── [feature].types.ts         ← TypeScript interfaces for this module
```

The repository lives inside its feature's module, not in a shared top-level `repositories/` folder. `models/` (the ORM model definitions) stays a separate top-level folder.

Cross-cutting concerns live in `core/`: `config.ts`, `database.ts`, `middleware/` (`auth.middleware.ts`, `error.middleware.ts`, `rate-limit.middleware.ts`), `utils/` (`response.ts`, `logger.ts`, `async-handler.ts`).

### Violation examples (AI will refuse to generate these)

```typescript
// ✗ WRONG – routes.ts importing the model and doing business logic
import { User } from '../models/user.model';
router.post('/login', asyncHandler(async (req, res) => {
  const user = await User.findOne({ where: { email: req.body.email } });
  if (user.role === 'admin') { /* ... */ }
}));

// ✓ CORRECT – routes.ts only delegates
router.post('/login', asyncHandler(async (req, res) => {
  const result = await authService.login(req.body);
  res.json(result);
}));
```

- `*.routes.ts` NEVER imports a model to query it directly.
- `*.routes.ts` NEVER contains conditionals that express business rules (`if (user.role === 'admin')`) — that belongs in the service.
- Every DB query lives in `*.repository.ts`, injected into the service via constructor.

### Setup commands

```bash
cd backend
cp .env.example .env
pnpm install
pnpm dev
```
