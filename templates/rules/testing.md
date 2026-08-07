---
title: Testing Rules
slug: testing
applies_to: always
cursor_globs: **/*.spec.ts,**/*.test.ts,**/test_*.py
copilot_apply_to: **/*.spec.ts,**/*.test.ts,**/test_*.py
cline_globs: **/*.spec.ts,**/*.test.ts,**/test_*.py
---

- Coverage target: 80% minimum.
- Unit tests alongside source (`*.spec.ts` or `test_*.py`); integration tests in `tests/integration/`; e2e in `tests/e2e/`.
- Mock external services — NEVER call real APIs in unit tests.
- Test naming describes behavior, not "should": ✓ `"returns 401 when token is expired"`, ✗ `"should return 401 when token is expired"`.
