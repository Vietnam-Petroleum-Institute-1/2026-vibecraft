# VibeCraft

Bộ công cụ chuẩn hóa "vibe coding" (AI-assisted coding) — biến code AI sinh ra thành code đủ chuẩn production: nhất quán style, bảo mật by-default, đúng MVC + module, có CI/CD và security scan tích hợp sẵn, dùng chung được cho cả team dù mỗi người dùng AI coding tool khác nhau.

> Repo này được sinh ra dựa trên spec ở `vibecraft-docs/` (repo planning riêng) và extend từ base repo [`obviousworks/vibe-coding-ai-rules`](https://github.com/obviousworks/vibe-coding-ai-rules). Xem `plans/` trong repo planning để biết chi tiết từng giai đoạn build và các quyết định kỹ thuật phát sinh.

## Vì sao cần VibeCraft

AI coding tool (Claude, Cursor, Copilot, ...) sinh code nhanh nhưng không tự nhất quán về kiến trúc, không tự chặn secret bị hardcode, không tự có CI. VibeCraft giải quyết việc đó bằng 4 lớp, áp dụng ngay từ lúc khởi tạo project, không phụ thuộc AI nào cụ thể:

1. **AI Rules** — 1 file `AGENTS.md` duy nhất mô tả kiến trúc/bảo mật/style, fan-out tự động ra định dạng riêng của 10 AI tool khác nhau
2. **Code Quality Config** — ESLint/Prettier/tsconfig (TypeScript) hoặc ruff/mypy/pyproject (Python), pin version chính xác, đã test thật
3. **Security Tools** — pre-commit hook (gitleaks chặn secret, lint chặn code bẩn trước khi commit được)
4. **CI/CD** — 3 GitHub Actions workflow (PR check, push main, security scan định kỳ), Actions pin theo commit SHA, không bao giờ `@main`

## Cài đặt

### Cách 1 — chạy `init.sh` trực tiếp

```bash
git clone <repo-url> vibecraft
cd your-project
../vibecraft/scripts/init.sh
```

Không truyền flag nào → chạy interactive mode, script tự hỏi từng câu (AI tool nào, project type nào, ngôn ngữ/framework nào, ...).

**Yêu cầu**: Bash. Trên Windows cần Git Bash (đi kèm Git for Windows) hoặc WSL — `init.sh`/`symlink-setup.sh` là script Bash thuần, không chạy được trực tiếp trên `cmd.exe`/PowerShell. Trên macOS/Linux, Bash đã có sẵn.

### Cách 2 — cài qua AI agent hỗ trợ Skill (Claude Code)

Copy hoặc symlink `skills/vibecraft-init/` vào `.claude/skills/vibecraft-init/` của project đích (hoặc `~/.claude/skills/vibecraft-init/` để dùng chung mọi project), sau đó gõ `/vibecraft-init` trong Claude Code. Skill sẽ hỏi lại đúng các câu hỏi của `init.sh` qua chat rồi tự chạy script ở flag mode — không cần gõ bash tay, không có logic nào khác với Cách 1 (skill chỉ là lớp UX, gọi lại `scripts/init.sh` làm nguồn sự thật duy nhất). Các AI không hỗ trợ khái niệm Skill cài được (Cursor, Copilot, Windsurf, ...) dùng thẳng Cách 1 — kết quả sinh ra giống hệt nhau.

### Cách 3 — cài qua `npx` (GitHub private nội bộ, không cần clone/dọn dẹp)

```bash
npx github:<org>/<repo>#<tag> --type app-be-only --lang python --framework fastapi
```

`npx` tự clone repo vào cache tạm của npm, chạy xong không để lại gì trong project — không cần `git clone` tay rồi tự xóa. Vì repo host trên GitHub private nội bộ (không phải npm registry công khai), cần có quyền truy cập repo sẵn có (SSH key hoặc PAT; nếu org bật SSO enforcement thì phải authorize trước). Nên luôn ghim `#<tag>` (git tag semver) thay vì để mặc định nhánh, tránh rủi ro nội dung đổi ngầm giữa các lần chạy. Không truyền flag → chạy interactive mode y hệt Cách 1 (wrapper chỉ forward stdin/stdout/args sang `scripts/init.sh`, không có logic riêng). Vẫn cần Bash (Git Bash/WSL trên Windows) — xem mục "Yêu cầu" ở Cách 1.

## Project types

| Type | Mô tả | Có `backend/`? | Có `frontend/`? |
|------|-------|:---:|:---:|
| `app-fullstack` | Full-stack app có FE + BE | ✓ | ✓ |
| `app-be-only` | Chỉ BE: API server, microservice | ✓ | – |
| `app-fe-only` | Chỉ FE: BE đã có sẵn ở project khác, tái sử dụng qua API base URL | – | ✓ (ở root) |
| `tool-script` | CLI tool, script, utility (có thể có hoặc không có HTTP) | – (mọi thứ ở root) | – |

Framework hỗ trợ: **NestJS** hoặc **Express** (TypeScript), **FastAPI** hoặc plain script (Python) cho backend/tool; **Next.js**, **React + Vite**, hoặc **Vue 3 + Vite** cho frontend.

```bash
# Full-stack, đủ flag — silent mode, không hỏi gì
./scripts/init.sh --type app-fullstack --lang typescript --framework nestjs --fe nextjs

# Chỉ frontend, backend đã có sẵn nơi khác
./scripts/init.sh --type app-fe-only --fe nextjs --api-url https://api.example.com

# CLI tool Python không có HTTP
./scripts/init.sh --type tool-script --lang python --framework script

# Chỉ chọn AI tool cụ thể thay vì mặc định cả 10
./scripts/init.sh --ai claude-code,cursor --type app-be-only --lang python

# Xem trước sẽ tạo gì, không ghi file thật
./scripts/init.sh --type app-be-only --lang python --dry-run

./scripts/init.sh --help
```

Truyền thiếu flag nào, script chỉ hỏi đúng phần còn thiếu (hybrid mode) — không hỏi lại những gì đã truyền qua flag.

## Sau khi chạy `init.sh`

Script tự in ra "Next steps" phù hợp với đúng tổ hợp type/lang/framework vừa chọn (lệnh cài dependency, tạo `.env`, lệnh chạy dev server). Với project có CI, script còn gợi ý `gh variable set PROJECT_TYPE=...`/`BACKEND_LANG=...`/`FRONTEND_FRAMEWORK=...` — cần chạy để các job CI biết bỏ qua phần nào project không có (vd `app-fe-only` không có job test backend).

Xem `docs/folder-structure.md` (đã copy vào project đích) để hiểu cây thư mục và rule MVC bắt buộc, và `docs/code-review-prompt.md` để có sẵn 1 prompt review code theo đúng rule trong `AGENTS.md`.

## Cấu trúc repo (chính `vibecraft/`, không phải project đích)

```
vibecraft/
├── scripts/
│   ├── init.sh                 ← Script cài đặt chính (interactive + flag + hybrid mode)
│   └── symlink-setup.sh        ← Fan-out AGENTS.md ra 10 AI IDE, gọi bởi init.sh
├── skills/vibecraft-init/      ← Cài đặt qua AI agent (Claude Code Skill), gọi lại init.sh
├── templates/                  ← Toàn bộ nội dung init.sh copy vào project đích
│   ├── agents/                 ← Mảnh AGENTS.md (base + per-framework + frontend)
│   ├── quality/                ← ESLint/Prettier/tsconfig, ruff/mypy/pyproject
│   ├── hooks/                  ← pre-commit config, husky, gitleaks
│   ├── ci/                     ← 3 GitHub Actions workflow, pin theo SHA
│   ├── docker/                 ← Dockerfile theo từng framework
│   └── structure/              ← Scaffold thư mục + code mẫu (module health) theo từng case
├── docs/                       ← Docs copy nguyên vào MỌI project đích (không phải doc của repo này)
└── .gitattributes              ← Ép eol=lf cho script Bash, tránh lỗi CRLF trên Windows
```

`docs/` ở đây là docs sẽ nằm trong project đích sau khi `init.sh` chạy xong (kế thừa từ `obviousworks/vibe-coding-ai-rules`, cộng `folder-structure.md`/`code-review-prompt.md` VibeCraft thêm) — khác với chính README này, chỉ dùng để hướng dẫn cài đặt VibeCraft.

## Hỗ trợ nhiều AI

`AGENTS.md` là single source of truth, fan-out tự động cho 10 AI tool bằng 3 cơ chế khác nhau tùy AI hỗ trợ gì:

| Cơ chế | AI tool | Kết quả |
|---|---|---|
| Symlink 1 file | Windsurf, Gemini CLI, Zed | `.windsurfrules`, `GEMINI.md`, `.rules` |
| Đọc `AGENTS.md` gốc, không cần file riêng | Codex, Aider | — |
| Multi-file rule pack theo chủ đề/glob | Cursor, GitHub Copilot, Cline, Claude Code, Continue | `.cursor/rules/*.mdc`, `.github/instructions/*.instructions.md`, `.clinerules/*.md`, `.claude/rules/*.md` + `CLAUDE.md`, `.continue/rules/*.md` |

Chọn AI tool nào cần setup qua `--ai` (hoặc câu hỏi tương tác đầu tiên) — mặc định tất cả 10, không bắt buộc chọn nếu team chỉ dùng 1-2 AI.

## MVC bắt buộc

Mọi backend framework (NestJS/Express/FastAPI) đều theo đúng 1 chain, không có ngoại lệ:

```
Controller/Router → Service → Repository → Model
```

Controller không được đụng ORM/DB trực tiếp; Service không import ORM model để query trực tiếp (đó là việc của Repository). Rule này nằm trong `AGENTS.md` sinh ra (không phải chỉ mô tả ở đây) — AI tạo code mới trong project đích sẽ tự đọc và tuân theo, xem chi tiết + ví dụ vi phạm trong `docs/code-review-prompt.md` của project đích.

## Ghi chú kỹ thuật

- Toàn bộ `templates/structure/*` đã được build + test thật (install, lint, type-check, build, unit/integration test, chạy server/CLI thật) cho cả 8 case, không chỉ review code.
- GitHub Actions trong `templates/ci/` pin theo commit SHA tra cứu qua GitHub API, kèm version tag ở comment — không dùng `@main`/`@master`/SHA đoán.
- Không dùng version range mở (`^`/`~`) cho dependency chính ở bất kỳ template nào — pin chính xác, đã xác nhận chạy được thật.
