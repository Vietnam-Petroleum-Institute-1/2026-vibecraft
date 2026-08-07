# Sample run — `/vibecraft-init`

A worked example of the skill in action, for an `app-be-only` FastAPI project. Shows the question flow (Steps 1–6), the resulting flag-mode command (Step 7), and how the result gets reported back (Step 8).

---

**User**: `/vibecraft-init`

**Agent**: I'll set up VibeCraft in the current directory (`payments-service/`). A few quick questions first.

Which AI coding tools does your team use? (pick any, or say "all")
1. Cursor 2. Windsurf 3. Claude Code 4. Cline 5. Gemini CLI 6. GitHub Copilot 7. Zed 8. Codex 9. Aider 10. Continue

**User**: just claude code and cursor

**Agent**: Got it — `claude-code, cursor`.

What kind of project is this?
1. `app-fullstack` — full-stack (backend + frontend)
2. `app-be-only` — backend only
3. `app-fe-only` — frontend only (backend already exists elsewhere)
4. `tool-script` — CLI tool or utility

**User**: backend only, it's a payments API

**Agent**: Backend language — TypeScript/JavaScript or Python?

**User**: python

**Agent**: Python + `app-be-only` → framework is FastAPI automatically, no further question needed there.

That's everything I need. Here's what I'm about to run:

```bash
bash ../vibecraft/scripts/init.sh \
  --ai "claude-code,cursor" \
  --type app-be-only \
  --lang python \
  --framework fastapi
```

Proceeding.

*(runs the command)*

**Agent**: Done. VibeCraft created:

- `backend/` — FastAPI app with the `Controller→Service→Repository→Model` chain (`src/main.py`, `modules/health/`, `repositories/`, `models/`), Alembic migrations, `tests/unit` + `tests/integration`
- `AGENTS.md` at the root, fanned out to `.claude/rules/*.md` + `CLAUDE.md` (Claude Code) and `.cursor/rules/*.mdc` (Cursor)
- `.pre-commit-config.yaml` (ruff, mypy, gitleaks), `.gitleaks.toml`
- `.github/workflows/{pr-check,push-main,scheduled-security}.yml`, GitHub Actions pinned to commit SHAs
- `backend/Dockerfile` + `.dockerignore`

Next steps (from the script):
1. `cd backend && python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt && cp .env.example .env`
2. `pre-commit install`
3. `uvicorn src.main:app --reload`
4. Configure CI variables: `gh variable set PROJECT_TYPE --body "app-be-only"` and `gh variable set BACKEND_LANG --body "python"`

---

## Variant: previewing first with `--dry-run`

If the user asks "show me what it'll do first" instead of just running it, Step 7 changes to two calls:

```bash
bash ../vibecraft/scripts/init.sh --ai "claude-code,cursor" --type app-be-only --lang python --framework fastapi --dry-run
```

Relay the `[dry-run] Would copy/write: ...` lines as a file-tree preview, then ask for confirmation before re-running the identical command without `--dry-run`.

## Variant: invalid combination caught before running

**User**: NestJS, but it's a Python project

**Agent**: NestJS requires TypeScript — `init.sh` will reject this combination outright (`validate()` exits with an error rather than silently guessing). For Python, the framework is FastAPI (backend/full-stack) or a choice between FastAPI and a plain script (`tool-script`). Which did you mean?
