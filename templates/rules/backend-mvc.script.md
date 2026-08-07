---
title: Backend Structure — Plain Script (tool-script)
slug: backend-mvc
applies_to: backend
cursor_globs: src/**/*
copilot_apply_to: src/**/*
cline_globs: src/**/*
---

This project has no full HTTP framework — it is a CLI tool or utility script. The MVC chain still applies at a reduced scale: `cli`/`commands` layer → `core`/`lib` (logic) → data access helpers, but there is no Controller/Router unless the tool exposes HTTP endpoints (see "If HTTP is added" below).

### Tech stack
- **Python**: `typer` or `click` for the CLI surface, `pyproject.toml` (ruff + black + mypy + pytest)
- **TypeScript/JS**: `commander` or `yargs` for the CLI surface, plain `tsconfig.json`

### Module structure

```
# Python
src/
  ├── __main__.py     ← `python -m toolname` entrypoint
  ├── cli.py           ← typer/click app, ONLY argument parsing + calls into core/
  ├── core/
  │   └── *.py         ← actual logic, no CLI-framework imports here
  ├── utils/
  └── config.py

# TypeScript/JS
src/
  ├── index.ts         ← entrypoint
  ├── cli/commands.ts   ← commander/yargs, ONLY argument parsing + calls into lib/
  ├── lib/*.ts          ← actual logic, no CLI-framework imports here
  ├── utils/
  └── types/
```

### Violation examples

```python
# ✗ WRONG – business logic mixed into the CLI command handler
@app.command()
def generate(name: str):
    if not name.isidentifier():
        raise typer.BadParameter("invalid name")
    with open(f"{name}.py", "w") as f:
        f.write(f"class {name}: pass")

# ✓ CORRECT – command handler only delegates
@app.command()
def generate(name: str):
    generator.generate_class(name)
```

### If HTTP is added later

Once the tool grows an HTTP endpoint, treat it like `app-be-only`: add `modules/api/router.py` (or `app.ts` + `routes/`) and follow the FastAPI/Express structure instead of this one. Do not bolt HTTP handling onto `cli.py`/`commands.ts` directly.

### Setup commands

```bash
# Python
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python -m toolname --help

# TypeScript/JS
pnpm install
pnpm build && node dist/index.js --help
```
