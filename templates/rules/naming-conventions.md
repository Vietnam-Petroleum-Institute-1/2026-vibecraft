---
title: Naming Conventions
slug: naming-conventions
applies_to: always
cursor_globs:
copilot_apply_to:
cline_globs:
---

**TypeScript**
- Files: `kebab-case.type.ts` (e.g. `create-user.dto.ts`, `auth.service.ts`)
- Classes: `PascalCase`
- Variables/functions: `camelCase` with auxiliary verbs (`isLoading`, `hasError`, `getUser`)
- Constants: `UPPER_SNAKE_CASE`
- Interfaces: `PascalCase`, no `I` prefix

**Python**
- Files: `snake_case.py`
- Classes: `PascalCase`
- Functions/variables: `snake_case`
- Constants: `UPPER_SNAKE_CASE`
- Pydantic models: `PascalCase` (e.g. `LoginRequest`, `TokenResponse`)
