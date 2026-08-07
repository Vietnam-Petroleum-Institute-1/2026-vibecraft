# Folder Structure

This project was scaffolded by [VibeCraft](https://github.com/obviousworks/vibe-coding-ai-rules) (`init.sh`). The exact folders present depend on which project type and framework were chosen at setup time — check `AGENTS.md`'s "Project Overview" section for this project's specific `[TYPE]`/`[LANG]`/`[FRAMEWORK]`/`[FE]` values. This document explains the *shape* every case shares, not a literal tree of every possible file.

## The one rule that applies to every case

**Folder structure is a contract, not a suggestion.** Do not add or remove top-level folders. A new feature is a new `modules/<feature>/` folder (backend) or `components/<feature>/` folder (frontend) — never a new top-level directory, and never files scattered loose into an existing unrelated module.

## The MVC chain (every backend framework)

```
Controller/Router → Service → Repository → Model
```

- **Controller/Router** (`*.controller.ts` / `router.py` / `*.routes.ts`): parses the request, validates input shape, calls exactly one service, returns the response. Never touches the database. Never contains business logic.
- **Service** (`*.service.ts` / `service.py`): all business logic lives here. May call multiple repositories and throw domain exceptions. Never imports an ORM model to query the database directly — that's the repository's job.
- **Repository** (`*.repository.ts` / `*_repository.py`): the only layer allowed to query the database. Returns domain objects, not raw rows. No business logic, no validation.
- **Model/Entity** (`*.entity.ts` / `models/*.py`): data definition only — ORM decorators/columns, nothing else.

Skipping a layer (e.g. a controller importing the ORM directly "just this once") is the single most common way AI-generated code drifts out of this structure. It's checked by `AGENTS.md`'s Architecture Rules section and should be checked again by hand — see `code-review-prompt.md` in this folder.

## Where things live, by project type

| `TYPE` | Has `backend/`? | Has `frontend/`? | Notes |
|---|---|---|---|
| `app-fullstack` | Yes | Yes | Full separation — the two never import from each other directly, only via HTTP |
| `app-be-only` | Yes | No | API server / microservice |
| `app-fe-only` | **No** | Yes (at project root, not nested) | Backend already exists in a separate project. `services/api.client.ts` is the *only* place that reads the API base URL env var — never call `fetch`/`axios` directly from a component |
| `tool-script` | No backend/frontend split — everything at project root | No | CLI tool or utility. If it has HTTP endpoints (a "yes" during setup), it still keeps the MVC chain above; if not, it's `cli/` (argument parsing only) → `lib/`/`core/` (the actual logic) |

## Inside `backend/` (or project root, for `tool-script`)

```
src/
├── main.ts|py            # bootstrap only — no business logic
├── core/                  # config, cross-cutting middleware/filters/interceptors
├── modules/<feature>/     # one folder per feature: controller + service + DTOs live together
├── repositories/          # one file per aggregate/entity
└── entities|models/       # ORM definitions
tests/
├── unit/                  # mirrors src/ structure, mocks all I/O
├── integration/           # real DB (test instance), real HTTP layer
└── e2e/                   # NestJS only — full app bootstrap
```

## Inside `frontend/`

```
src/
├── app|main.tsx|App.vue   # entry point, framework-specific
├── components/
│   ├── common/            # reusable, no business/domain logic
│   └── features/          # one folder per domain feature
├── services/               # ALL API calls go through here — never inline fetch/axios in components
├── hooks|composables/      # framework-specific reusable stateful logic
├── types/                  # types matching the API contract — update these first when the contract changes, never guess a field
└── utils/
```

## If this file and the actual project disagree

Treat the generated project + `AGENTS.md` as current — this file describes the general shape shared across every VibeCraft project type, not a guarantee that nothing has evolved since your project was scaffolded.
