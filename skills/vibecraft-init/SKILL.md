---
name: vibecraft-init
description: Install VibeCraft's production-ready guardrails (AGENTS.md fan-out, ESLint/Prettier/ruff/mypy configs, pre-commit + gitleaks, GitHub Actions CI/CD, Dockerfile, MVC folder scaffold) into the current project. Use when the user asks to "set up VibeCraft", "init vibecraft", "add vibe coding guardrails", or wants production-ready structure/CI/security tooling bootstrapped for a new or existing project.
---

# VibeCraft Init

This skill installs VibeCraft into the user's **current project directory** by collecting the same inputs `scripts/init.sh` would ask interactively, then invoking that exact script in flag mode. It does not reimplement any decision logic — every question and validation rule here is a direct mirror of `scripts/init.sh` (see that file's `ask_*`/`validate()` functions). If this skill's questions ever seem to disagree with what `init.sh` actually does, `init.sh` is the source of truth; fix this file, not the other way around.

**Why flag mode, not interactive mode**: `init.sh` also supports asking its own questions via `read -rp` when run with no flags. Don't rely on that here — the Bash tool (and most agent runtimes) cannot pipe answers into a running subprocess's stdin, so an unattended `read` would hang forever. Always collect every answer through chat first, then call `init.sh` with a fully-formed flag list (silent/flag mode), never partial flags that would trigger `init.sh`'s own interactive fallback.

## Step 0 — Locate `scripts/init.sh`

This skill ships inside a VibeCraft checkout. Resolve `scripts/init.sh` and `templates/` relative to this `SKILL.md`'s own location (two directories up: `skills/vibecraft-init/SKILL.md` → `../../scripts/init.sh`). If that path doesn't exist, tell the user VibeCraft isn't checked out correctly and stop — do not fall back to writing files by hand.

Confirm the target directory with the user (default: current working directory). Warn if it's non-empty and not already a git repo — VibeCraft writes into it, not into a fresh subfolder.

## Step 1 — Ask which AI coding tools the team uses

Mirrors `ask_ai_tools()`. Ask the user (multi-select, default = all):

1. Cursor
2. Windsurf
3. Claude Code
4. Cline
5. Gemini CLI
6. GitHub Copilot
7. Zed
8. Codex
9. Aider
10. Continue

If the user has no preference or says "all"/"whatever the team uses", pick all 10 — this only controls which AI config files (`.cursor/rules/`, `CLAUDE.md`, `.windsurfrules`, etc.) get generated; it never limits functionality.

Collect the picks into a comma-separated value for `--ai`, e.g. `claude-code,cursor`.

## Step 2 — Ask project type

Mirrors `ask_type()`. Exactly one of:

| Value | Meaning |
|---|---|
| `app-fullstack` | Full-stack app: backend + frontend |
| `app-be-only` | Backend only |
| `app-fe-only` | Frontend only — a separate backend already exists elsewhere |
| `tool-script` | CLI tool or utility script, no web app |

## Step 3 — Ask backend language + framework (skip entirely for `app-fe-only`)

If `TYPE == app-fe-only`, skip this whole step — go to Step 4. `app-fe-only` projects never get a `backend/` folder, language, or framework; asking would contradict `validate()`, which clears `--lang`/`--framework` for this type anyway.

Otherwise, mirrors `ask_lang()` then the framework sub-questions:

1. Ask backend language: **TypeScript/JavaScript** or **Python**.
2. Framework, branching on language and type (mirrors `fill_missing()`'s framework logic exactly):
   - **TypeScript + `tool-script`**: ask `ask_http_js()` — "Does this tool have HTTP endpoints?" → Yes = `express`, No = `script` (plain CLI, no HTTP deps). Never offer NestJS for a tool.
   - **TypeScript + anything else** (`app-fullstack`/`app-be-only`): ask `ask_nestjs()` — "Use NestJS?" → Yes = `nestjs`, No = `express`.
   - **Python + `tool-script`**: ask `ask_http()` — "Does this tool have HTTP endpoints?" → Yes = `fastapi`, No = `script`.
   - **Python + anything else**: framework is always `fastapi`, no question needed.

## Step 4 — Ask frontend framework (only for `app-fullstack` or `app-fe-only`)

Mirrors `ask_fe()`. Skip for `app-be-only` and `tool-script` — a frontend value there gets silently discarded by `validate()` anyway, so don't collect it.

Options: **Next.js** (recommended) / **React + Vite** / **Vue 3 + Vite**.

## Step 5 — `app-fe-only` only: ask the existing backend's API base URL

Mirrors `ask_api_url()`. Optional — the user can leave it blank and fill in `.env.local` later. Skip this question entirely for every other project type.

## Step 6 — Validate the combination before running anything

Mirror `validate()` exactly — do this in your own reasoning, don't just pass bad combinations through to the script and hope it errors cleanly:

- NestJS is never valid for `tool-script` — if picked, switch to `express` and tell the user why (matches `init.sh`'s auto-correct + warning, not a hard error).
- Python can never pair with `nestjs` or `express` — these require TypeScript. If the user somehow lands here, stop and re-ask the framework question; don't call `init.sh` with an invalid combination (it will `exit 1`).
- A frontend framework has no effect outside `app-fullstack`/`app-fe-only` — don't collect or pass one.

## Step 7 — Build the flag-mode command and run it

Construct one call, then run it with the Bash tool from inside the target directory:

```bash
bash <vibecraft-root>/scripts/init.sh \
  --ai "<comma-separated AI tools>" \
  --type <app-fullstack|app-be-only|app-fe-only|tool-script> \
  [--lang <typescript|python>] \
  [--framework <nestjs|express|fastapi|script>] \
  [--fe <nextjs|react-vite|vue-vite>] \
  [--api-url "<url>"] \
  [--name "<project name>"]
```

Omit `--lang`/`--framework` entirely for `app-fe-only`. Omit `--fe`/`--api-url` for `app-be-only`/`tool-script`. Every flag value must be exactly one of the tokens listed above — these are matched literally by `init.sh`'s `case` statements, not fuzzy-matched.

Run it for real (no `--dry-run`) unless the user explicitly asked for a preview first — in that case, run once with `--dry-run` to show what would be created, then run again for real after they confirm.

## Step 8 — Report the result

Summarize what `init.sh` printed: the file tree it created, the "Next steps" section (dependency install commands, `.env` setup, dev-server start command), and the `gh variable set` hints for CI if it printed any. Don't re-derive these yourself — relay the script's actual output, since it already accounts for the specific type/framework combination.

If `init.sh` exits non-zero, show the actual error (it already explains itself — e.g. "NestJS requires TypeScript") rather than guessing what went wrong.

## Non-goals

This skill does not:
- Reimplement or "improve on" `init.sh`'s logic in Markdown — every rule above is a description of existing script behavior, not new behavior. If `init.sh` changes, update this file to match, in that order.
- Perform code review or enforce coding standards after install — that's what the generated `AGENTS.md` + CI + pre-commit hooks do, for every AI tool, not just Claude Code. See `../../plans/00-MASTER-PLAN.md` for why a Claude-only review skill was deliberately not built.
- Work for AI tools that don't support installable Skills (Cursor, Copilot, etc.) — those users run `scripts/init.sh` directly. The generated project works identically either way; this skill is a Claude Code-specific UX shortcut for installation only.
