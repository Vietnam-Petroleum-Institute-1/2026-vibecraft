# Code Review Prompt

A copy-paste-ready prompt for asking any AI coding tool to review a diff or file against this project's own `AGENTS.md` rules — useful because linters/CI catch syntax and style issues, but not architectural drift (a controller quietly importing the ORM, a component calling `fetch` directly). Works with any AI (Claude, Cursor, Copilot, ...) since it only refers to `AGENTS.md`, which every one of them can read.

## The prompt

```
Review the following code change against this project's AGENTS.md rules,
specifically the Architecture Rules and Security Rules sections. For each
file changed, check:

1. Layer boundaries (MVC chain: Controller/Router → Service → Repository → Model)
   - Does the Controller/Router ONLY parse input, call one service, and return
     the response — no business logic, no direct DB/ORM access?
   - Does the Service avoid importing an ORM model to query the DB directly
     (that's the Repository's job)?
   - Does the Repository stay free of business logic and validation?
   - Does the Model/Entity contain ONLY data definition — no methods with logic?
   - Frontend only: does every API call go through services/*.service.ts —
     no inline fetch/axios in a component?

2. Folder placement
   - Is this a genuinely new feature (→ new modules/<feature>/ or
     components/<feature>/ folder), or does it belong inside an existing
     module? Flag anything added to an unrelated existing module.
   - No new top-level folders outside what AGENTS.md's Project Overview lists.

3. Security (see AGENTS.md Security Rules)
   - Any hardcoded secret, API key, token, or password? Must be an env var,
     never a literal.
   - Is every user input validated at the Controller/Router level (DTOs /
     Zod / Pydantic), not deeper in the stack or not at all?
   - Any raw string interpolation into a SQL query instead of a
     parameterized query / ORM call?
   - Does anything trust a client-sent user ID instead of the authenticated
     token's claims?

4. Error handling & async
   - Any swallowed exception (empty catch block, or a catch that only logs
     without re-throwing/returning an error response)?
   - Any unhandled Promise rejection, or async logic mixed with raw
     callbacks?

5. Tests
   - Does new business logic have a corresponding unit test?
   - Do unit tests call real external services/APIs instead of mocking them?

For each finding, cite the specific AGENTS.md rule it violates, the file and
line, and a one-line fix. Do not flag stylistic preferences that ESLint/
Prettier/ruff/black would already catch — this review is for the things
automated formatting and linting cannot see.
```

## When to use this

- Before opening a PR, on your own diff, as a self-check the same way you'd run the linter.
- As a reviewer, pasted alongside the actual diff, when you want the AI to check architecture instead of (or in addition to) reading it yourself.
- This is *not* a replacement for the automated gates already in this project (ESLint/Prettier/ruff/mypy pre-commit hooks, CI lint/test/security-scan jobs) — those catch what's mechanically checkable and run on every AI tool without anyone needing to remember to ask. This prompt exists for the architectural judgment calls those tools structurally cannot make.
