# VibeCraft

Bộ công cụ chuẩn hóa "vibe coding" (code AI sinh ra) thành code đủ chuẩn production: nhất quán style, chặn secret lộ ra ngoài, đúng kiến trúc, có sẵn CI/CD — dùng chung được cho cả team dù mỗi người dùng AI khác nhau (Claude, Cursor, Copilot...).

## Vì sao cần VibeCraft

AI coding tool sinh code nhanh nhưng không tự nhất quán về kiến trúc, không tự chặn secret bị hardcode, không tự có CI. VibeCraft giải quyết bằng 4 lớp, thiết lập sẵn ngay từ lúc khởi tạo project:

1. **AI Rules** — 1 file duy nhất mô tả kiến trúc/bảo mật/style, tự áp dụng cho mọi AI coding tool team đang dùng
2. **Code Quality** — ESLint/Prettier (TypeScript) hoặc ruff/mypy (Python), cấu hình sẵn
3. **Chặn lỗi trước khi commit** — tự động chặn secret bị hardcode và code không đạt chuẩn
4. **CI/CD** — tự động kiểm tra + scan bảo mật mỗi khi có code mới

## Cài đặt

Chọn 1 trong các cách dưới đây, tuỳ bạn đang dùng AI tool nào.

### Cách 1 — chạy script trực tiếp

```bash
git clone <repo-url> vibecraft
cd your-project
../vibecraft/scripts/init.sh
```

Không cần truyền gì thêm — script sẽ tự hỏi bạn từng câu (dùng AI tool nào, loại project gì, ngôn ngữ/framework nào...).

**Yêu cầu**: có Bash. Windows cần cài Git Bash (đi kèm khi cài Git for Windows). macOS/Linux đã có sẵn.

### Cách 2 — cài qua Claude Code (gõ lệnh, không cần nhớ cú pháp)

```
/plugin marketplace add PVN-Organization/vibecraft
/plugin install vibecraft@vibecraft-marketplace
```

Sau khi cài, gõ `/vibecraft:vibecraft-init` trong Claude Code ở bất kỳ project nào — nó sẽ hỏi bạn các câu tương tự Cách 1 rồi tự thiết lập, không cần gõ lệnh bash tay.

Cập nhật bản mới sau này:
```
/plugin marketplace update vibecraft-marketplace
/plugin update vibecraft@vibecraft-marketplace
```

**Không ghi version → luôn lấy bản mới nhất.** Muốn ghim đúng 1 bản cụ thể (không tự đổi khi có bản mới), thêm `#<tag>` vào cuối URL lúc thêm marketplace:
```
/plugin marketplace add https://github.com/PVN-Organization/vibecraft.git#v0.2.0
```

Dùng Cursor, Codex CLI hay GitHub Copilot thay vì Claude Code? Các tool này cũng cài được VibeCraft theo cách riêng của chúng — hỏi mình nếu cần hướng dẫn cụ thể cho tool bạn đang dùng.

### Cách 3 — cài qua `npx` (không cần tự dọn dẹp sau khi cài)

```bash
npx github:PVN-Organization/vibecraft
```

Không truyền flag → hỏi từng câu như Cách 1. Vẫn cần Bash (xem mục "Yêu cầu" ở Cách 1).

**Không ghi version → luôn lấy bản mới nhất**, y hệt Cách 2. Muốn ghim đúng 1 bản, thêm `#<tag>` vào cuối:
```bash
npx github:PVN-Organization/vibecraft#v0.2.0
```

Muốn trả lời sẵn luôn thay vì để script hỏi, thêm flag ở cuối, ví dụ:
```bash
npx github:PVN-Organization/vibecraft --type app-be-only --lang python --framework fastapi
```

## Loại project hỗ trợ

| Loại | Mô tả |
|------|-------|
| `app-fullstack` | Full-stack — có cả backend lẫn frontend |
| `app-be-only` | Chỉ backend — API server, microservice |
| `app-fe-only` | Chỉ frontend — backend đã có sẵn ở nơi khác |
| `tool-script` | CLI tool, script tiện ích |

Framework hỗ trợ: **NestJS** hoặc **Express** (TypeScript), **FastAPI** hoặc script thuần (Python) cho backend; **Next.js**, **React + Vite**, hoặc **Vue 3 + Vite** cho frontend.

```bash
# Full-stack, trả lời sẵn hết — không hỏi gì thêm
./scripts/init.sh --type app-fullstack --lang typescript --framework nestjs --fe nextjs

# Chỉ frontend, backend đã có sẵn nơi khác
./scripts/init.sh --type app-fe-only --fe nextjs --api-url https://api.example.com

# Xem trước sẽ tạo ra gì, chưa ghi file thật
./scripts/init.sh --type app-be-only --lang python --dry-run

./scripts/init.sh --help
```

Thiếu flag nào, script chỉ hỏi đúng phần còn thiếu — không hỏi lại những gì đã trả lời rồi.

## Sau khi cài xong

Script sẽ in ra các bước tiếp theo phù hợp với lựa chọn của bạn: lệnh cài dependency, tạo file môi trường, lệnh chạy thử project.

Trong project vừa tạo, xem thêm `docs/folder-structure.md` để hiểu cây thư mục, và `docs/code-review-prompt.md` để có sẵn 1 prompt review code theo đúng chuẩn VibeCraft đã thiết lập.

## Dùng chung cho cả team, dù mỗi người dùng AI khác nhau

VibeCraft tự thiết lập rule cho tới 10 AI coding tool khác nhau (Cursor, Windsurf, Claude Code, Cline, Gemini CLI, GitHub Copilot, Zed, Codex, Aider, Continue) — mỗi người trong team chỉ cần dùng đúng AI mình quen, không cần cả team thống nhất dùng 1 AI.

Muốn chỉ thiết lập cho 1-2 AI team đang dùng thay vì cả 10, truyền `--ai`, ví dụ: `./scripts/init.sh --ai claude-code,cursor`.

## Kiến trúc bắt buộc

Mọi backend đều theo đúng 1 luồng, không có ngoại lệ:

```
Controller/Router → Service → Repository → Model
```

Controller không được đụng thẳng vào database; mọi thao tác dữ liệu phải qua đúng lớp của nó. AI tạo code mới trong project sẽ tự đọc và tuân theo rule này.

## Phát hành bản mới (dành cho maintainer)

Các ví dụ ghim version ở trên (`#v0.2.0` trong URL `npx`/`/plugin marketplace add`) chỉ hoạt động nếu tag đó thực sự tồn tại trên GitHub — bump số version trong `package.json`/`plugin.json`/`.claude-plugin/plugin.json` không tự tạo ra tag. Sau khi commit phần code + bump version:

```bash
git tag v0.2.0
git push origin v0.2.0
```

Thiếu bước push tag này, mọi ví dụ `#v0.2.0` trong README sẽ ra lỗi "ref not found" cho tới khi tag được tạo.
