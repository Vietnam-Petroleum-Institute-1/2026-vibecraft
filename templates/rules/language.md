---
title: Language Convention
slug: language
applies_to: always
cursor_globs:
copilot_apply_to:
cline_globs:
---

- **Code identifiers** (variables, functions, types, DB table/column names): always English — see the Naming Conventions rule, no exceptions regardless of the project's target market.
- **Comments**: [COMMENT_LANG]. Only write one when intent isn't obvious from the code (a constraint, a business reason, a workaround for a specific bug) — never restate what the line already says.
- **User-facing strings** (error messages shown to the end user, UI labels): [UI_STRING_LANG]. Keep them short and free of internal/technical detail (no stack traces, no raw SQL, no internal error codes) — see the Security rule on not leaking implementation details.
