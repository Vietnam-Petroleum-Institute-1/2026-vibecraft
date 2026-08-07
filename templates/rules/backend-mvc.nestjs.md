---
title: Backend Structure — NestJS
slug: backend-mvc
applies_to: backend
cursor_globs: backend/**/*.ts
copilot_apply_to: backend/**/*.ts
cline_globs: backend/**/*.ts
---

### Tech stack (Backend)
- **Framework**: NestJS 10 · **Language**: TypeScript 5.x
- **ORM/DB**: TypeORM + PostgreSQL (or Prisma — confirm with the project's `package.json` before assuming)
- **Auth**: `@nestjs/passport` + JWT (access + refresh)
- **Package manager**: pnpm

### Module structure

```
modules/[feature]/
  ├── [feature].module.ts        ← @Module({ controllers, providers, imports })
  ├── [feature].controller.ts    ← @Controller('[feature]') — Controller in MVC
  ├── [feature].service.ts       ← @Injectable() — business logic
  ├── [feature].repository.ts    ← @Injectable() — ONLY layer allowed to query the DB
  ├── [feature].guard.ts         ← optional, auth/role guard
  └── dto/
      └── *.dto.ts               ← class-validator DTOs
```

The repository lives inside its feature's module, not in a shared top-level `repositories/` folder. `entities/` (the `@Entity()` classes) stays a separate top-level folder.

Cross-cutting concerns live in `core/`: `config/`, `filters/` (exception filters), `interceptors/`, `pipes/` (validation), `middleware/`.

### Violation examples (AI will refuse to generate these)

```typescript
// ✗ WRONG – business logic + repo access in controller
@Post('/login')
async login(@Body() dto: LoginDto) {
  const user = await this.userRepo.findByEmail(dto.email);
  if (!user || !bcrypt.compare(dto.password, user.hash)) {
    throw new UnauthorizedException();
  }
}

// ✓ CORRECT – controller only delegates
@Post('/login')
async login(@Body() dto: LoginDto) {
  return this.authService.login(dto);
}
```

- Controller NEVER imports `Repository`/DB session directly.
- Service NEVER imports an `@Entity()` class to query it directly — it calls the repository.
- `*.entity.ts` NEVER has a method that contains business logic (validation, calculations) — data shape only.

### Setup commands

```bash
cd backend
cp .env.example .env
pnpm install
pnpm run migration:run
pnpm run start:dev
```
