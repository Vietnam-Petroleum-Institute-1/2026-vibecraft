#!/usr/bin/env bash
# VibeCraft Init Script
# Usage: ./init.sh [--ai TOOLS] [--type TYPE] [--lang LANG] [--framework FW] [--fe FE]
# Based on: obviousworks/vibe-coding-ai-rules

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Paths ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIBECRAFT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$VIBECRAFT_ROOT/templates"
TARGET_DIR="${PWD}"
PROJECT_NAME="$(basename "$TARGET_DIR")"

# ── Default values ───────────────────────────────────────────
AI_TOOLS=""   # comma-separated; empty means "not yet chosen", defaults to claude-code if never asked
TYPE=""
LANG=""
FRAMEWORK=""
FE=""
API_URL=""
LANG_CONVENTION=""
PROJECT_NAME_OVERRIDE=""
SKIP_DOCKER=false
SKIP_CI=false
DRY_RUN=false
FORCE=false

# ── Functions ────────────────────────────────────────────────
print_banner() {
  echo -e "${CYAN}${BOLD}"
  echo "  ╦  ╦╦╔╗  ╔═╗  ╔═╗╦═╗╔═╗╔═╗╔╦╗"
  echo "  ╚╗╔╝║╠╩╗ ║╣   ║  ╠╦╝╠═╣╠╣  ║"
  echo "   ╚╝ ╩╚═╝ ╚═╝  ╚═╝╩╚═╩ ╩╚   ╩"
  echo -e "${NC}"
  echo -e "  ${BOLD}VibeCraft Init${NC} – Production-ready vibe coding setup"
  echo -e "  Target: ${BLUE}$TARGET_DIR${NC}"
  echo ""
}

log_info()    { echo -e "  ${BLUE}→${NC} $1"; }
log_success() { echo -e "  ${GREEN}✓${NC} $1"; }
log_warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
log_error()   { echo -e "  ${RED}✗${NC} $1" >&2; }

copy_file() {
  local src="$1"
  local dst="$2"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "  ${YELLOW}[dry-run]${NC} Would copy: $src → $dst"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    log_success "$(basename "$dst")"
  fi
}

write_file() {
  local dst="$1"
  local content="$2"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "  ${YELLOW}[dry-run]${NC} Would write: $dst"
  else
    mkdir -p "$(dirname "$dst")"
    echo "$content" > "$dst"
    log_success "$(basename "$dst")"
  fi
}

# ── Guard against silently clobbering an existing directory ────
# write_file/copy_file/copy_tree above (and symlink-setup.sh's own
# link_or_copy/deep-tool generators) all overwrite unconditionally by
# design — that's the correct behavior for AI-config resync (re-run after
# hand-editing AGENTS.md to fan changes back out). But the very first run
# of init.sh in a directory that already has real content (hand-written
# backend/frontend code, a pre-existing AGENTS.md from another tool, ...)
# has no such "resync" justification — it would silently destroy that
# content. Check for VibeCraft's own top-level output paths before
# generating anything; if any exist, require either an explicit y/N
# confirmation (interactive) or --force (flag/CI mode) before proceeding.
check_existing_files() {
  local candidates=(
    AGENTS.md CLAUDE.md GEMINI.md
    backend frontend src docs
    Dockerfile .dockerignore
    .github .husky .agents .gemini .claude .cursor .clinerules .continue
    .windsurfrules .rules
    package.json tsconfig.json pyproject.toml requirements.txt
    .pre-commit-config.yaml .gitleaks.toml .editorconfig .eslintrc.json .prettierrc
  )
  local existing=() p
  for p in "${candidates[@]}"; do
    [[ -e "$TARGET_DIR/$p" ]] && existing+=("$p")
  done
  [[ ${#existing[@]} -eq 0 ]] && return 0

  log_warn "Target directory already contains: ${existing[*]}"
  if [[ "$FORCE" == "true" ]]; then
    log_warn "--force given — these will be overwritten without further confirmation."
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    log_warn "--dry-run: would ask to overwrite these (no files will actually be written)."
    return 0
  fi

  echo ""
  read -rp "  Overwrite these existing files/folders? (y/N): " confirm
  case "$confirm" in
    y|Y|yes|YES) return 0 ;;
    *)
      log_error "Aborted — no files changed. Re-run in an empty directory, or pass --force to overwrite."
      exit 1
      ;;
  esac
}

show_help() {
  cat <<EOF
Usage: vibecraft init [options]

Options:
  --ai        Comma-separated AI tool(s) to set up rules for (default: claude-code)
              cursor | windsurf | claude-code | cline | gemini-cli |
              github-copilot | zed | codex | aider | continue
  --type      app-fullstack | app-be-only | app-fe-only | tool-script
  --lang      typescript (ts, js) | python (py) [ignored for app-fe-only]
  --framework nestjs | express | fastapi | script [ignored for app-fe-only]
  --fe        nextjs | react-vite | vue-vite
  --api-url   External API base URL [app-fe-only only, optional]
  --lang-convention  Language for comments & user-facing strings: en (default) | vi | free text
  --name      Project name (default: current directory)
  --no-docker Skip Dockerfile generation
  --no-ci     Skip GitHub Actions generation
  --dry-run   Preview without creating files
  --force     Overwrite existing files/folders without prompting
  -h, --help  Show this help

Examples:
  ./init.sh
  ./init.sh --type app-fullstack --lang typescript --framework nestjs --fe nextjs
  ./init.sh --type app-be-only --lang python
  ./init.sh --type tool-script --lang python --dry-run
  ./init.sh --ai claude-code,cursor --type app-be-only --lang python
EOF
}

# ── Parse flags ──────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --ai)         AI_TOOLS="$2";              shift 2 ;;
    --type)       TYPE="$2";                  shift 2 ;;
    --lang)       LANG="$2";                  shift 2 ;;
    --framework)  FRAMEWORK="$2";             shift 2 ;;
    --fe)         FE="$2";                    shift 2 ;;
    --api-url)    API_URL="$2";               shift 2 ;;
    --lang-convention) LANG_CONVENTION="$2";  shift 2 ;;
    --name)       PROJECT_NAME_OVERRIDE="$2"; shift 2 ;;
    --no-docker)  SKIP_DOCKER=true;           shift ;;
    --no-ci)      SKIP_CI=true;               shift ;;
    --dry-run)    DRY_RUN=true;               shift ;;
    --force)      FORCE=true;                 shift ;;
    -h|--help)    show_help; exit 0 ;;
    *)            log_error "Unknown flag: $1"; show_help; exit 1 ;;
  esac
done

[[ -n "$PROJECT_NAME_OVERRIDE" ]] && PROJECT_NAME="$PROJECT_NAME_OVERRIDE"

# --ai flag comes in comma-separated ("claude-code,cursor"); symlink-setup.sh
# and the internal `wants()`-style checks expect space-separated.
[[ -n "$AI_TOOLS" ]] && AI_TOOLS="$(echo "$AI_TOOLS" | tr ',' ' ' | xargs)"

# ── Interactive questions ────────────────────────────────────
ask_ai_tools() {
  echo ""
  echo -e "  ${BOLD}? Team dùng AI coding tool nào? (nhiều lựa chọn, cách nhau bởi dấu phẩy, Enter = Claude Code)${NC}"
  echo "    1) Cursor            6) GitHub Copilot"
  echo "    2) Windsurf          7) Zed"
  echo "    3) Claude Code       8) Codex"
  echo "    4) Cline             9) Aider"
  echo "    5) Gemini CLI       10) Continue"
  read -rp "  Choice(s) [Enter = Claude Code]: " choices

  if [[ -z "$choices" ]]; then
    AI_TOOLS="claude-code"
    return
  fi

  local map=(cursor windsurf claude-code cline gemini-cli github-copilot zed codex aider continue)
  AI_TOOLS=""
  IFS=',' read -ra picks <<< "$choices"
  for p in "${picks[@]}"; do
    p="$(echo "$p" | tr -d ' ')"
    if [[ "$p" =~ ^[0-9]+$ && "$p" -ge 1 && "$p" -le 10 ]]; then
      AI_TOOLS="$AI_TOOLS ${map[$((p-1))]}"
    else
      log_warn "Bỏ qua lựa chọn không hợp lệ: $p"
    fi
  done
  AI_TOOLS="$(echo "$AI_TOOLS" | xargs)" # trim
  [[ -z "$AI_TOOLS" ]] && { log_warn "Không chọn được AI nào hợp lệ, hỏi lại"; ask_ai_tools; }
  # Explicit `return 0`: without it, whenever the line above's `[[ -z ... ]]`
  # test is FALSE (the normal case — user picked at least one valid tool),
  # this is the LAST command bash actually runs in the function, so
  # ask_ai_tools's own implicit exit status becomes 1. Its caller,
  # `[[ -z "$AI_TOOLS" ]] && ask_ai_tools` in fill_missing(), then sees
  # ask_ai_tools (the final command in that && list) fail, and under
  # `set -e` a plain top-level statement failing kills the ENTIRE script —
  # silently, no error message, right after the very first question. Only
  # surfaced by a real user picking a valid AI tool interactively; every
  # flag-mode/`--dry-run` test up to now passed `--ai` directly and never
  # exercised this code path. See plans/07-init-script.md.
  return 0
}

ask_type() {
  echo ""
  echo -e "  ${BOLD}? Project type:${NC}"
  echo "    1) app-fullstack  – Full-stack with FE + BE"
  echo "    2) app-be-only    – Backend only"
  echo "    3) app-fe-only    – Frontend only (BE đã có sẵn ở project khác)"
  echo "    4) tool-script    – CLI tool or utility"
  read -rp "  Choice [1-4]: " choice
  case $choice in
    1) TYPE="app-fullstack" ;;
    2) TYPE="app-be-only" ;;
    3) TYPE="app-fe-only" ;;
    4) TYPE="tool-script" ;;
    *) log_error "Invalid choice"; ask_type ;;
  esac
}

ask_lang() {
  echo ""
  echo -e "  ${BOLD}? Backend language:${NC}"
  echo "    1) TypeScript / JavaScript"
  echo "    2) Python"
  read -rp "  Choice [1-2]: " choice
  case $choice in
    1) LANG="typescript" ;;
    2) LANG="python" ;;
    *) log_error "Invalid choice"; ask_lang ;;
  esac
}

ask_nestjs() {
  echo ""
  echo -e "  ${BOLD}? Use NestJS?${NC}"
  echo "    1) Yes – NestJS (recommended for large apps, MVC built-in)"
  echo "    2) No  – Express.js (lightweight, manual MVC structure)"
  read -rp "  Choice [1-2]: " choice
  case $choice in
    1) FRAMEWORK="nestjs" ;;
    2) FRAMEWORK="express" ;;
    *) log_error "Invalid choice"; ask_nestjs ;;
  esac
}

ask_http() {
  echo ""
  echo -e "  ${BOLD}? Does this tool have HTTP endpoints?${NC}"
  echo "    1) Yes – Use FastAPI"
  echo "    2) No  – Plain Python script"
  read -rp "  Choice [1-2]: " choice
  case $choice in
    1) FRAMEWORK="fastapi" ;;
    2) FRAMEWORK="script" ;;
    *) log_error "Invalid choice"; ask_http ;;
  esac
}

ask_http_js() {
  echo ""
  echo -e "  ${BOLD}? Does this tool have HTTP endpoints?${NC}"
  echo "    1) Yes – Use Express (NestJS not offered — not worth the overhead for a tool)"
  echo "    2) No  – Plain CLI tool (commander, no HTTP deps)"
  read -rp "  Choice [1-2]: " choice
  case $choice in
    1) FRAMEWORK="express" ;;
    2) FRAMEWORK="script" ;;
    *) log_error "Invalid choice"; ask_http_js ;;
  esac
}

ask_fe() {
  echo ""
  echo -e "  ${BOLD}? Frontend framework:${NC}"
  echo "    1) Next.js       [recommended]"
  echo "    2) React + Vite"
  echo "    3) Vue 3 + Vite"
  read -rp "  Choice [1-3]: " choice
  case $choice in
    1) FE="nextjs" ;;
    2) FE="react-vite" ;;
    3) FE="vue-vite" ;;
    *) log_error "Invalid choice"; ask_fe ;;
  esac
}

ask_lang_convention() {
  echo ""
  echo -e "  ${BOLD}? Language for comments & user-facing strings:${NC}"
  echo "    1) English    [default]"
  echo "    2) Vietnamese"
  echo "    3) Other (type it in)"
  read -rp "  Choice [1-3, Enter = 1]: " choice
  case "$choice" in
    ""|1) LANG_CONVENTION="en" ;;
    2)    LANG_CONVENTION="vi" ;;
    3)    read -rp "  Language name: " LANG_CONVENTION ;;
    *)    log_error "Invalid choice"; ask_lang_convention ;;
  esac
}

ask_api_url() {
  echo ""
  echo -e "  ${BOLD}? API base URL của BE có sẵn?${NC} (để trống nếu điền sau trong .env)"
  # `|| true`: `read`'s own exit status (nonzero on real EOF, e.g. a genuine
  # interactive terminal closed with Ctrl+D) would otherwise become this
  # function's return status — and since this is the last command
  # `[[ -z "$API_URL" ]] && ask_api_url` in fill_missing() runs, a nonzero
  # here kills the whole script under `set -e` (same failure class as the
  # ask_ai_tools bug above). Falling back to an empty API_URL matches what
  # this prompt already tells the user is fine ("để trống nếu điền sau").
  read -rp "  URL: " API_URL || true
}

# ── Fill in missing values interactively ─────────────────────
fill_missing() {
  [[ -z "$AI_TOOLS" ]] && ask_ai_tools

  [[ -z "$TYPE" ]] && ask_type
  [[ -z "$LANG_CONVENTION" ]] && ask_lang_convention

  # app-fe-only: KHÔNG hỏi lang/framework BE, chỉ hỏi FE + API URL
  if [[ "$TYPE" == "app-fe-only" ]]; then
    LANG=""
    FRAMEWORK=""
    [[ -z "$FE" ]] && ask_fe
    [[ -z "$API_URL" ]] && ask_api_url
    # Explicit `return 0`, not bare `return`: with no arg, `return` propagates
    # the exit status of the last command run above — the `[[ -z "$API_URL" ]]`
    # test, which is FALSE (exit 1) whenever --api-url was already supplied.
    # That 1 then becomes fill_missing's own exit status back in main(), and
    # under `set -e` a plain top-level statement failing kills the whole
    # script. Only surfaced by actually running `--type app-fe-only --fe ...
    # --api-url ...` with both flags pre-filled — see plans/07-init-script.md.
    return 0
  fi

  # Normalize lang aliases
  case "$LANG" in
    ts|js|javascript) LANG="typescript" ;;
    py|py3)           LANG="python" ;;
  esac

  [[ -z "$LANG" ]] && ask_lang

  # Framework logic
  if [[ -z "$FRAMEWORK" ]]; then
    if [[ "$LANG" == "typescript" ]]; then
      if [[ "$TYPE" == "tool-script" ]]; then
        ask_http_js  # script (CLI-only, commander) or express (has HTTP) — never NestJS for tools
      else
        ask_nestjs
      fi
    elif [[ "$LANG" == "python" ]]; then
      if [[ "$TYPE" == "tool-script" ]]; then
        ask_http
      else
        FRAMEWORK="fastapi"  # Auto
        log_info "Python → using FastAPI"
      fi
    fi
  fi

  # FE logic
  if [[ "$TYPE" == "app-fullstack" && -z "$FE" ]]; then
    ask_fe
  fi
}

# ── Validate combinations ────────────────────────────────────
validate() {
  if [[ "$FRAMEWORK" == "nestjs" && "$TYPE" == "tool-script" ]]; then
    log_warn "NestJS is not recommended for tool-script. Switching to Express.js."
    FRAMEWORK="express"
  fi

  if [[ "$LANG" == "python" && "$FRAMEWORK" == "nestjs" ]]; then
    log_error "NestJS requires TypeScript. Use fastapi for Python."
    exit 1
  fi

  if [[ "$LANG" == "python" && "$FRAMEWORK" == "express" ]]; then
    log_error "Express requires TypeScript. Use fastapi for Python."
    exit 1
  fi

  if [[ "$TYPE" != "app-fullstack" && "$TYPE" != "app-fe-only" && -n "$FE" ]]; then
    log_warn "FE framework ignored for non-fullstack/fe-only projects."
    FE=""
  fi

  if [[ "$TYPE" == "app-fe-only" && ( -n "$LANG" || -n "$FRAMEWORK" ) ]]; then
    log_warn "Backend lang/framework ignored for app-fe-only (BE already exists elsewhere)."
    LANG=""
    FRAMEWORK=""
  fi
}

# ── Print summary ─────────────────────────────────────────────
print_summary() {
  echo ""
  echo -e "  ${BOLD}Setup Summary:${NC}"
  echo -e "  ├── Project:    ${CYAN}$PROJECT_NAME${NC}"
  echo -e "  ├── AI tools:   ${CYAN}$AI_TOOLS${NC}"
  echo -e "  ├── Type:       ${CYAN}$TYPE${NC}"
  if [[ "$TYPE" != "app-fe-only" ]]; then
    echo -e "  ├── BE Lang:    ${CYAN}$LANG${NC}"
    echo -e "  ├── Framework:  ${CYAN}$FRAMEWORK${NC}"
  fi
  [[ -n "$FE" ]] && echo -e "  ├── FE:         ${CYAN}$FE${NC}"
  [[ "$TYPE" == "app-fe-only" ]] && echo -e "  ├── API URL:    ${CYAN}${API_URL:-<chưa điền, sửa .env sau>}${NC}"
  echo -e "  ├── Docker:     ${CYAN}$([[ "$SKIP_DOCKER" == "true" ]] && echo "skip" || echo "yes")${NC}"
  echo -e "  └── CI/CD:      ${CYAN}$([[ "$SKIP_CI" == "true" ]] && echo "skip" || echo "yes")${NC}"
  echo ""

  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "  ${YELLOW}[DRY RUN MODE – no files will be created]${NC}"
    echo ""
  fi
}

# ── Generate AGENTS.md from atomic rule templates ──────────────
# AGENTS.md is assembled once here from templates/rules/*.md (each an
# independent, front-matter-tagged topic — see templates/rules/*.md for the
# schema). Every section is wrapped in an HTML-comment marker carrying its
# slug + per-tool hint fields, so symlink-setup.sh can re-split a (possibly
# hand-edited) AGENTS.md later without re-reading these template sources —
# AGENTS.md itself stays the single, portable source of truth.

# Order matters only for readability of the assembled AGENTS.md; applicability
# is decided per-section by `applies_to`, not by this list.
RULE_ORDER=(architecture naming-conventions backend-mvc frontend-structure security code-style testing git-workflow performance ai-permissions clean-code logging api-design code-review language workflow-contract)

# section_applies <applies_to> — true if this section belongs in the current
# project's AGENTS.md, given $TYPE/$FRAMEWORK/$FE already resolved.
section_applies() {
  case "$1" in
    always)   return 0 ;;
    backend)  [[ "$TYPE" != "app-fe-only" ]] ;;
    frontend) [[ -n "$FE" ]] ;;
    has-api)  [[ "$TYPE" != "app-fe-only" && "$FRAMEWORK" != "script" ]] ;;
    app-only) [[ "$TYPE" != "tool-script" ]] ;;
    fastapi)  [[ "$FRAMEWORK" == "fastapi" ]] ;;
    react)    [[ "$FE" == "nextjs" || "$FE" == "react-vite" ]] ;;
    *)        return 1 ;;
  esac
}

# rule_template_path <slug> — backend-mvc has one source file per framework,
# resolved to $FRAMEWORK; every other slug maps 1:1 to its own template file.
rule_template_path() {
  if [[ "$1" == "backend-mvc" ]]; then
    echo "$TEMPLATES_DIR/rules/backend-mvc.$FRAMEWORK.md"
  else
    echo "$TEMPLATES_DIR/rules/$1.md"
  fi
}

generate_agents_md() {
  log_info "Generating AGENTS.md..."

  local agents_content
  # Filled via `read -d ''` instead of `agents_content=$(cat <<'EOF' ... EOF)`:
  # a heredoc nested inside command substitution, inside a function, is a
  # documented cross-bash-version fragility (parses fine in the bash 5.x used
  # for all local/CI testing here, but produces a "syntax error near
  # unexpected token" far below this point under macOS's stock bash 3.2 —
  # only caught by a real user running the npx-installed script on a Mac, not
  # by any test in this repo, which never runs under bash <4). `read -d ''`
  # reads a heredoc straight into a variable with no command substitution
  # involved, sidestepping the fragile pattern entirely.
  IFS= read -r -d '' agents_content <<'EOF' || true
# AGENTS.md – [PROJECT_NAME]
> Universal AI coding configuration. Extends: obviousworks/vibe-coding-ai-rules
> Type: [TYPE] | Last updated: [DATE] | Version: 1.0.0

This file is generated by VibeCraft (`init.sh`) from atomic rule templates. It is symlinked/copied to every AI IDE's native config file (`.cursorrules`, `CLAUDE.md`, `.windsurfrules`, `.clinerules`, `GEMINI.md`, `.github/copilot-instructions.md`, `.rules`) and split into per-topic files for tools that support it (Cursor, GitHub Copilot, Cline, Claude Code, Continue). **Edit this file only** — never edit the fan-out copies directly, they are overwritten on the next `symlink-setup.sh` run. The `<!-- vibecraft:section ... -->` markers are what makes that re-split possible; keep them intact if you hand-edit a section.

---

## 1. Project Overview

**Project name**: [PROJECT_NAME]
**Type**: [TYPE]
**Backend language**: [LANG]
**Framework**: [FRAMEWORK]
**Frontend**: [FE]

---
EOF

  local n=2 slug src applies_to title cursor_globs copilot_apply_to cline_globs body
  for slug in "${RULE_ORDER[@]}"; do
    src=$(rule_template_path "$slug")
    [[ -f "$src" ]] || continue

    applies_to=$(sed -n 's/^applies_to: *//p' "$src" | head -1)
    section_applies "$applies_to" || continue

    title=$(sed -n 's/^title: *//p' "$src" | head -1)
    cursor_globs=$(sed -n 's/^cursor_globs: *//p' "$src" | head -1)
    copilot_apply_to=$(sed -n 's/^copilot_apply_to: *//p' "$src" | head -1)
    cline_globs=$(sed -n 's/^cline_globs: *//p' "$src" | head -1)
    body=$(awk 'BEGIN{n=0; started=0} /^---$/{n++; next} n>=2{ if (!started && $0=="") next; started=1; print }' "$src")

    agents_content+=$'\n\n'
    agents_content+="<!-- vibecraft:section slug=\"$slug\" cursor_globs=\"$cursor_globs\" copilot_apply_to=\"$copilot_apply_to\" cline_globs=\"$cline_globs\" -->"
    agents_content+=$'\n'"## $n. $title"$'\n\n'
    agents_content+="$body"
    agents_content+=$'\n'"<!-- vibecraft:endsection -->"$'\n\n---'
    n=$((n + 1))
  done

  agents_content+=$'\n\n'"*Maintained by VibeCraft · Version: 1.0.0 · Updated: [DATE]*"

  # Replace placeholders
  agents_content="${agents_content//\[PROJECT_NAME\]/$PROJECT_NAME}"
  agents_content="${agents_content//\[TYPE\]/$TYPE}"
  agents_content="${agents_content//\[LANG\]/$LANG}"
  agents_content="${agents_content//\[FRAMEWORK\]/$FRAMEWORK}"
  agents_content="${agents_content//\[FE\]/$FE}"
  agents_content="${agents_content//\[API_URL\]/$API_URL}"
  agents_content="${agents_content//\[DATE\]/$(date +%Y-%m-%d)}"
  agents_content="${agents_content//\[COMMENT_LANG\]/$COMMENT_LANG}"
  agents_content="${agents_content//\[UI_STRING_LANG\]/$UI_STRING_LANG}"

  write_file "$TARGET_DIR/AGENTS.md" "$agents_content"
}

# ── Generate structure ────────────────────────────────────────
copy_tree() {
  # copy_tree <src_dir> <dst_dir> — like `cp -r src/. dst/`, but honors
  # DRY_RUN instead of always writing (the original spec called `cp -r`
  # directly for every structure/docs copy, which meant `--dry-run` still
  # created every backend/frontend file for real — only caught by running
  # `--dry-run` and diffing the resulting tree against an empty one).
  local src="$1" dst="$2"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "  ${YELLOW}[dry-run]${NC} Would copy tree: $src → $dst"
  else
    mkdir -p "$dst"
    cp -r "$src/." "$dst/"
  fi
}

generate_structure() {
  log_info "Creating folder structure..."

  # app-fe-only: không có backend/, bỏ qua toàn bộ nhánh framework BE
  if [[ "$TYPE" != "app-fe-only" ]]; then
    # tool-script has no backend/ split (03-FOLDER-STRUCTURES.md Case 6 keeps
    # everything at project root) — this also applies when a tool has HTTP
    # (ask_http/ask_http_js sets FRAMEWORK=fastapi/express in that case, the
    # same values app-be-only/app-fullstack use). Reusing the express-be/
    # fastapi-be templates for a tool's HTTP variant is a deliberate reuse,
    # not a new template — but they must land at $TARGET_DIR directly, not
    # $TARGET_DIR/backend/, or they end up split across two roots (structure
    # in backend/, but package.json/tsconfig/pyproject/Dockerfile written to
    # $TARGET_DIR by generate_quality/generate_docker, which already treat
    # tool-script as root-level). Caught by actually running
    # `--type tool-script --framework express` end to end, not by review.
    local be_target="$TARGET_DIR/backend"
    [[ "$TYPE" == "tool-script" ]] && be_target="$TARGET_DIR"

    case "$FRAMEWORK" in
      nestjs)
        copy_tree "$TEMPLATES_DIR/structure/nestjs-be" "$be_target"
        ;;
      express)
        copy_tree "$TEMPLATES_DIR/structure/express-be" "$be_target"
        ;;
      fastapi)
        copy_tree "$TEMPLATES_DIR/structure/fastapi-be" "$be_target"
        ;;
      script)
        # Copied to TARGET_DIR root, NOT TARGET_DIR/src/ — the template
        # already contains its own src/ and tests/ subfolders (tool-script
        # has no backend/frontend split, everything lives at project root).
        # An earlier version of this script copied into TARGET_DIR/src/,
        # which double-nested the template's own src/ into src/src/ — caught
        # by actually running this against a real project, see
        # plans/06-folder-structure-scaffolds.md.
        if [[ "$LANG" == "python" ]]; then
          copy_tree "$TEMPLATES_DIR/structure/python-tool" "$TARGET_DIR"
        else
          copy_tree "$TEMPLATES_DIR/structure/js-tool" "$TARGET_DIR"
        fi
        ;;
    esac
  fi

  if [[ -n "$FE" ]]; then
    case "$FE" in
      nextjs)     copy_tree "$TEMPLATES_DIR/structure/nextjs-fe" "$TARGET_DIR/frontend" ;;
      react-vite) copy_tree "$TEMPLATES_DIR/structure/react-vite-fe" "$TARGET_DIR/frontend" ;;
      vue-vite)   copy_tree "$TEMPLATES_DIR/structure/vue-vite-fe" "$TARGET_DIR/frontend" ;;
    esac

    if [[ "$TYPE" == "app-fe-only" ]]; then
      # Ghi API_URL vào .env.example của FE thay vì backend
      local env_var="NEXT_PUBLIC_API_URL"
      [[ "$FE" != "nextjs" ]] && env_var="VITE_API_URL"
      write_file "$TARGET_DIR/frontend/.env.example" "${env_var}=${API_URL}"
    fi
  fi
}

# ── Generate quality configs ──────────────────────────────────
generate_quality() {
  log_info "Generating code quality configs..."

  # Shared
  copy_file "$TEMPLATES_DIR/quality/shared/.editorconfig"       "$TARGET_DIR/.editorconfig"
  copy_file "$TEMPLATES_DIR/quality/shared/gitignore.template"  "$TARGET_DIR/.gitignore"
  copy_file "$TEMPLATES_DIR/quality/shared/commitlint.config.js" "$TARGET_DIR/commitlint.config.js"

  if [[ "$LANG" == "typescript" ]]; then
    local be_dir="$TARGET_DIR/backend"
    [[ "$TYPE" == "tool-script" ]] && be_dir="$TARGET_DIR"

    copy_file "$TEMPLATES_DIR/quality/js/.prettierrc"           "$be_dir/.prettierrc"
    copy_file "$TEMPLATES_DIR/quality/js/.eslintrc.json"        "$be_dir/.eslintrc.json"
    copy_file "$TEMPLATES_DIR/quality/js/tsconfig.base.json"    "$be_dir/tsconfig.json"
    # tsconfig.build.json (NestJS/Express/js-tool only) already came from
    # generate_structure()'s per-case structure/ copy — nothing to do here.
    copy_file "$TEMPLATES_DIR/quality/js/package.$FRAMEWORK.json" "$be_dir/package.json"
  fi

  if [[ "$LANG" == "python" ]]; then
    local be_dir="$TARGET_DIR/backend"
    [[ "$TYPE" == "tool-script" ]] && be_dir="$TARGET_DIR"

    # Plain script (no HTTP) needs typer, not the FastAPI/SQLAlchemy/pydantic
    # stack — pyproject.toml's [tool.mypy] plugins=["pydantic.mypy"] errors
    # out if pydantic isn't installed, so this needs its own pyproject too,
    # not just its own requirements file.
    if [[ "$FRAMEWORK" == "script" ]]; then
      copy_file "$TEMPLATES_DIR/quality/python/pyproject.tool.toml"    "$be_dir/pyproject.toml"
      copy_file "$TEMPLATES_DIR/quality/python/requirements.tool.txt"  "$be_dir/requirements.txt"
    else
      copy_file "$TEMPLATES_DIR/quality/python/pyproject.toml"         "$be_dir/pyproject.toml"
      copy_file "$TEMPLATES_DIR/quality/python/requirements.base.txt"  "$be_dir/requirements.txt"
    fi
  fi

  # Frontend configs
  if [[ -n "$FE" ]]; then
    local fe_dir="$TARGET_DIR/frontend"
    copy_file "$TEMPLATES_DIR/quality/js/.prettierrc"             "$fe_dir/.prettierrc"

    case "$FE" in
      nextjs)
        copy_file "$TEMPLATES_DIR/quality/js/.eslintrc.nextjs.json" "$fe_dir/.eslintrc.json"
        copy_file "$TEMPLATES_DIR/quality/js/tsconfig.nextjs.json"  "$fe_dir/tsconfig.json"
        ;;
      react-vite)
        copy_file "$TEMPLATES_DIR/quality/js/.eslintrc.react.json"  "$fe_dir/.eslintrc.json"
        copy_file "$TEMPLATES_DIR/quality/js/tsconfig.vite.json"    "$fe_dir/tsconfig.json"
        ;;
      vue-vite)
        copy_file "$TEMPLATES_DIR/quality/js/.eslintrc.vue.json"    "$fe_dir/.eslintrc.json"
        copy_file "$TEMPLATES_DIR/quality/js/tsconfig.vite.json"    "$fe_dir/tsconfig.json"
        ;;
    esac
  fi
}

# ── Generate hooks ────────────────────────────────────────────
generate_hooks() {
  log_info "Setting up git hooks..."

  # Pre-commit (Python / JS / mixed) — picked by combination, not just $LANG,
  # so a fullstack Python backend + JS/TS frontend gets ruff/mypy correctly
  # scoped to backend/ instead of the plain single-language configs.
  if [[ "$LANG" == "python" && -z "$FE" ]]; then
    copy_file "$TEMPLATES_DIR/hooks/.pre-commit-config.python.yaml" "$TARGET_DIR/.pre-commit-config.yaml"
  elif [[ "$LANG" == "python" && -n "$FE" ]]; then
    copy_file "$TEMPLATES_DIR/hooks/.pre-commit-config.shared.yaml" "$TARGET_DIR/.pre-commit-config.yaml"
  else
    copy_file "$TEMPLATES_DIR/hooks/.pre-commit-config.js.yaml" "$TARGET_DIR/.pre-commit-config.yaml"
  fi

  copy_file "$TEMPLATES_DIR/hooks/.gitleaks.toml" "$TARGET_DIR/.gitleaks.toml"

  # Husky (JS/TS anywhere in the project) — ALWAYS at project root. git
  # resolves a relative core.hooksPath from the repo's top-level directory
  # regardless of where `npm install`/`husky` ran, so a nested backend/.husky
  # or frontend/.husky is never actually found by git; it silently no-ops
  # and — once "prepare": "husky" sets core.hooksPath — also disables
  # whatever `pre-commit install` wired up. Husky must be the single owner
  # of core.hooksPath, and its pre-commit script (templates/hooks/husky/pre-commit)
  # chains into `pre-commit run` so Python/gitleaks checks still execute.
  if [[ "$LANG" == "typescript" || -n "$FE" ]]; then
    copy_file "$TEMPLATES_DIR/hooks/husky/pre-commit" "$TARGET_DIR/.husky/pre-commit"
    copy_file "$TEMPLATES_DIR/hooks/husky/commit-msg" "$TARGET_DIR/.husky/commit-msg"
    if [[ "$DRY_RUN" == "false" ]]; then
      chmod +x "$TARGET_DIR/.husky/pre-commit" 2>/dev/null || true
      chmod +x "$TARGET_DIR/.husky/commit-msg" 2>/dev/null || true
    fi

    # tool-script's own package.json already lives at TARGET_DIR and already
    # owns husky/lint-staged/prepare directly — no separate root package.json.
    if [[ "$TYPE" != "tool-script" ]]; then
      local root_pkg_src="$TEMPLATES_DIR/hooks/package.root.fullstack.json"
      if [[ "$TYPE" == "app-be-only" ]]; then
        root_pkg_src="$TEMPLATES_DIR/hooks/package.root.be-only.json"
      elif [[ "$TYPE" == "app-fe-only" ]]; then
        root_pkg_src="$TEMPLATES_DIR/hooks/package.root.fe-only.json"
      elif [[ "$TYPE" == "app-fullstack" && "$LANG" == "python" ]]; then
        root_pkg_src="$TEMPLATES_DIR/hooks/package.root.fullstack-py.json"
      fi

      local root_pkg_content
      root_pkg_content=$(cat "$root_pkg_src")
      root_pkg_content="${root_pkg_content//\[PROJECT_NAME\]/$PROJECT_NAME}"
      write_file "$TARGET_DIR/package.json" "$root_pkg_content"
    fi
  fi
}

# ── Generate Docker ───────────────────────────────────────────
generate_docker() {
  [[ "$SKIP_DOCKER" == "true" ]] && return
  [[ "$TYPE" == "app-fe-only" ]] && return  # Không có BE để Dockerize; FE Dockerfile là opt-in riêng, không mặc định
  [[ "$FRAMEWORK" == "script" ]] && return  # Plain CLI tool — no Dockerfile template for this case

  log_info "Generating Dockerfile..."
  local be_dir="$TARGET_DIR/backend"
  [[ "$TYPE" == "tool-script" ]] && be_dir="$TARGET_DIR"

  copy_file "$TEMPLATES_DIR/docker/Dockerfile.$FRAMEWORK" "$be_dir/Dockerfile"
  copy_file "$TEMPLATES_DIR/docker/.dockerignore"         "$be_dir/.dockerignore"
}

# ── Generate CI ───────────────────────────────────────────────
generate_ci() {
  [[ "$SKIP_CI" == "true" ]] && return
  [[ "$TYPE" == "tool-script" ]] && return  # Tools don't need full CI

  log_info "Generating GitHub Actions workflows..."

  copy_file "$TEMPLATES_DIR/ci/pr-check.yml"            "$TARGET_DIR/.github/workflows/pr-check.yml"
  copy_file "$TEMPLATES_DIR/ci/push-main.yml"           "$TARGET_DIR/.github/workflows/push-main.yml"

  # scheduled-security.yml chứa Dep-Check/Lynis cho BE + server chạy lâu dài — bỏ qua với app-fe-only
  if [[ "$TYPE" != "app-fe-only" ]]; then
    copy_file "$TEMPLATES_DIR/ci/scheduled-security.yml"  "$TARGET_DIR/.github/workflows/scheduled-security.yml"
  fi
}

# ── Scaffold an empty docs/ for the project's own documentation ─
# AI coding rules live in AGENTS.md + the per-tool fan-out (.claude/rules/
# etc.), not here — this folder is intentionally NOT pre-filled with
# VibeCraft's own long-form reference docs (real projects don't ship those
# either, see plans/00-MASTER-PLAN.md). It exists so there's an obvious,
# conventional place for the project's OWN documentation (API contracts,
# ERDs, runbooks) instead of no folder at all.
generate_docs() {
  log_info "Scaffolding docs/..."
  # See generate_agents_md()'s comment on the same `read -d ''` pattern —
  # avoids nesting a heredoc inside command substitution, which is fragile
  # across bash versions (fine under bash 5.x, breaks under macOS's bash 3.2).
  local docs_readme
  IFS= read -r -d '' docs_readme <<'EOF' || true
# docs/

Project-specific documentation goes here (API contracts, ERDs, runbooks,
architecture decision records, etc.).

AI coding rules do NOT live here — see `AGENTS.md` at the project root and
its per-tool fan-out (`.claude/rules/`, `.cursor/rules/`, and so on).
EOF
  write_file "$TARGET_DIR/docs/README.md" "$docs_readme"
}

# ── Generate project skills, fanned out to every AI tool that has a
# confirmed official skill-directory convention ────────────────────────
# Pure UX convenience — the actual behavioral contract for anything a skill
# covers already lives in a normal rule template in AGENTS.md (see
# generate_agents_md()), so no rule lives only in a skill file.
#
# "Skill" (a SKILL.md file with name/description front-matter) started as a
# Claude Code feature but is now an open cross-tool standard — each tool
# still scans its OWN directory for it, there is no shared path. Only tools
# with a directory confirmed against that tool's own official docs (as of
# 2026-08) are wired up here; unconfirmed tools are deliberately skipped
# rather than guessed:
#   claude-code    .claude/skills/<name>/SKILL.md
#   cursor         .cursor/skills/<name>/SKILL.md
#   codex          .agents/skills/<name>/SKILL.md   (NOT .codex/ — that dir is user-home-only)
#   gemini-cli     .gemini/skills/<name>/SKILL.md
#   github-copilot .github/skills/<name>/SKILL.md
#   windsurf       .windsurf/skills/<name>/SKILL.md
# cline/continue/zed/aider have no authoritatively-confirmed skill path yet —
# they still get the same behavioral content via AGENTS.md / their rule
# fan-out (run_symlinks), just not as a standalone skill file. Revisit this
# list if/when those tools publish (or this project reconfirms) a convention;
# that refresh is deliberately out of scope for now.
#
# SKILL_ORDER — every skill VibeCraft knows how to generate. Each maps to
# templates/skills/<slug>/SKILL.md, whose own `applies_to` front-matter
# (checked via section_applies(), same values as RULE_ORDER) decides whether
# it's generated for this project — no per-skill bash conditional needed
# here, adding a new skill is just dropping a new template file + slug.
SKILL_ORDER=(codeagent security-audit code-review testing performance database docker backend frontend ui-design ui-design-review python-api react)

# fanout_skill <slug> — writes templates/skills/<slug>/SKILL.md to all 6
# confirmed tool paths (only for tools actually in $AI_TOOLS). Placeholders
# filled: [VERIFY_COMMANDS] (codeagent only — a no-op replace for skills
# that don't contain it), [RULES_REF] (every skill — points at wherever
# *this* tool keeps its detailed per-topic rules, since deep tools split
# AGENTS.md and flat tools don't — see symlink-setup.sh).
fanout_skill() {
  local slug="$1"
  local skill_content notice_content=""
  skill_content=$(cat "$TEMPLATES_DIR/skills/$slug/SKILL.md")
  skill_content="${skill_content//\[VERIFY_COMMANDS\]/$MARKED_VERIFY_CMDS}"
  skill_content="${skill_content//@VIBECRAFT_AMP@/\&}"
  [[ -f "$TEMPLATES_DIR/skills/$slug/NOTICE.md" ]] && notice_content=$(cat "$TEMPLATES_DIR/skills/$slug/NOTICE.md")

  local write_skill
  write_skill() {
    local tool="$1" target="$2" rules_ref="$3"
    [[ " $AI_TOOLS " == *" $tool "* ]] || return 0
    write_file "$TARGET_DIR/$target" "${skill_content//\[RULES_REF\]/$rules_ref}"
    if [[ -n "$notice_content" ]]; then
      write_file "$TARGET_DIR/$(dirname "$target")/NOTICE.md" "$notice_content"
    fi
    return 0
  }
  write_skill claude-code    ".claude/skills/$slug/SKILL.md"   '`.claude/rules/*.md`'
  write_skill cursor         ".cursor/skills/$slug/SKILL.md"   '`.cursor/rules/*.mdc`'
  write_skill codex          ".agents/skills/$slug/SKILL.md"   '`AGENTS.md`'
  write_skill gemini-cli     ".gemini/skills/$slug/SKILL.md"   '`GEMINI.md`'
  write_skill github-copilot ".github/skills/$slug/SKILL.md"   '`.github/instructions/*.instructions.md`'
  write_skill windsurf       ".windsurf/skills/$slug/SKILL.md" '`.windsurfrules`'
}

generate_skills() {
  local verify_cmds=""
  if [[ "$TYPE" != "app-fe-only" && "$TYPE" != "tool-script" ]]; then
    if [[ "$LANG" == "python" ]]; then
      verify_cmds+="- Backend: \`cd backend && ruff check . && mypy src && pytest\`"$'\n'
    else
      verify_cmds+="- Backend: \`cd backend && pnpm run build && pnpm run lint && pnpm test\`"$'\n'
    fi
  fi
  if [[ -n "$FE" ]]; then
    verify_cmds+="- Frontend: \`cd frontend && pnpm run build && pnpm run lint && pnpm test\`"$'\n'
  fi

  # bash's `${var//pat/rep}` treats an unescaped `&` in `rep` as "insert the
  # matched text" (sed-like backreference) — verify_cmds contains literal
  # `&&` (shell command chaining), so substitute it in through a throwaway
  # marker instead of raw, or every `&&` corrupts into repeated "[VERIFY_COMMANDS]".
  MARKED_VERIFY_CMDS="${verify_cmds//&/@VIBECRAFT_AMP@}"

  local slug src applies_to
  for slug in "${SKILL_ORDER[@]}"; do
    src="$TEMPLATES_DIR/skills/$slug/SKILL.md"
    [[ -f "$src" ]] || continue
    applies_to=$(sed -n 's/^applies_to: *//p' "$src" | head -1)
    section_applies "$applies_to" || continue
    log_info "Generating $slug skill for selected AI tools..."
    fanout_skill "$slug"
  done
}

# ── Run symlink setup ─────────────────────────────────────────
run_symlinks() {
  log_info "Setting up AI rules for: $AI_TOOLS"
  if [[ "$DRY_RUN" == "false" ]]; then
    # shellcheck disable=SC2086 — intentional word-splitting: AI_TOOLS is a
    # space-separated list consumed as separate positional args by the script
    (cd "$TARGET_DIR" && bash "$VIBECRAFT_ROOT/scripts/symlink-setup.sh" $AI_TOOLS)
  else
    echo -e "  ${YELLOW}[dry-run]${NC} Would run symlink-setup.sh for: $AI_TOOLS"
  fi
}

# ── Install hooks ─────────────────────────────────────────────
install_hooks() {
  log_info "Installing hooks..."

  # Whenever husky is present (see generate_hooks()), it will claim
  # core.hooksPath the moment `npm install` runs at project root (its
  # "prepare" script) — and only ONE of husky/pre-commit can own
  # core.hooksPath at a time. So `pre-commit install`'s git-hook shims would
  # just get silently overridden; skip it and let husky's own pre-commit
  # script shell out to `pre-commit run` instead (see templates/hooks/husky/pre-commit).
  if [[ "$LANG" == "typescript" || -n "$FE" ]]; then
    log_info "Husky owns git hooks here — run 'npm install' (or pnpm/yarn) at the project root to activate them."
    return
  fi

  if [[ "$DRY_RUN" == "false" ]]; then
    if [[ ! -d "$TARGET_DIR/.git" ]]; then
      log_warn "Not a git repo yet — skipping 'pre-commit install'. Run 'git init' then 'pre-commit install' manually."
      return
    fi
    if [[ -f "$TARGET_DIR/.pre-commit-config.yaml" ]] && command -v pre-commit &>/dev/null; then
      (cd "$TARGET_DIR" && pre-commit install && pre-commit install --hook-type commit-msg)
      log_success "pre-commit installed"
    fi
  fi
}

# ── Print next steps ──────────────────────────────────────────
print_next_steps() {
  echo ""
  echo -e "  ${GREEN}${BOLD}Setup complete!${NC}"
  echo ""
  echo -e "  ${BOLD}Next steps:${NC}"
  echo ""

  if [[ "$TYPE" == "app-fe-only" ]]; then
    echo "  1. Install dependencies:"
    echo "     cd frontend && pnpm install"
    echo ""
    echo "  2. Setup environment (điền API URL nếu chưa điền lúc init):"
    echo "     cp .env.example .env.local"
    echo ""
    echo "  3. Start development:"
    echo "     pnpm dev"
  elif [[ "$LANG" == "python" ]]; then
    # tool-script has no backend/ split — everything lives at project root
    echo "  1. Setup Python environment:"
    [[ "$TYPE" != "tool-script" ]] && echo "     cd backend"
    echo "     python -m venv .venv && source .venv/bin/activate"
    echo "     pip install -r requirements.txt"
    echo "     cp .env.example .env"
    echo ""
    echo "  2. Install pre-commit hooks:"
    echo "     pre-commit install"
    echo ""
    if [[ "$FRAMEWORK" == "script" ]]; then
      echo "  3. Run the CLI:"
      echo "     python -m src.cli --help"
    else
      echo "  3. Start development:"
      echo "     uvicorn src.main:app --reload"
    fi
  else
    echo "  1. Install dependencies:"
    if [[ "$TYPE" == "tool-script" ]]; then
      echo "     pnpm install"
    else
      echo "     cd backend && pnpm install"
      [[ -n "$FE" ]] && echo "     cd ../frontend && pnpm install"
    fi
    echo ""
    echo "  2. Setup environment:"
    [[ "$FRAMEWORK" != "script" ]] && echo "     cp .env.example .env"
    echo ""
    echo "  3. Start development:"
    [[ "$FRAMEWORK" == "nestjs" ]] && echo "     cd backend && pnpm start:dev"
    [[ "$FRAMEWORK" == "express" && "$TYPE" != "tool-script" ]] && echo "     cd backend && pnpm dev"
    [[ "$FRAMEWORK" == "express" && "$TYPE" == "tool-script" ]] && echo "     pnpm dev   # or: pnpm build && pnpm start"
    [[ "$FRAMEWORK" == "script" ]] && echo "     pnpm build && node dist/index.js --help"
    [[ -n "$FE" ]] && echo "     cd frontend && pnpm dev"
  fi

  if [[ "$TYPE" != "tool-script" && ( "$LANG" == "typescript" || -n "$FE" ) ]]; then
    echo ""
    echo "  Also, at the project root (activates git hooks — lint-staged + commitlint):"
    echo "     npm install"
  fi

  if [[ "$SKIP_CI" == "false" && "$TYPE" != "tool-script" ]]; then
    echo ""
    echo "  4. Configure GitHub repo variables for CI (skip jobs for the parts you don't have):"
    echo "     gh variable set PROJECT_TYPE --body \"$TYPE\""
    [[ -n "$LANG" ]] && echo "     gh variable set BACKEND_LANG --body \"$LANG\""
    [[ -n "$FE" ]]   && echo "     gh variable set FRONTEND_FRAMEWORK --body \"$FE\""
    echo "     (xem .github/workflows/*.yml — mỗi job dùng if: để tự skip theo các biến này)"
  fi

  echo ""
  echo -e "  Files created in: ${CYAN}$TARGET_DIR${NC}"
  echo ""
}

# ── Resolve language-convention flag into placeholder values ──
resolve_lang_convention() {
  case "$LANG_CONVENTION" in
    ""|en) COMMENT_LANG="English";    UI_STRING_LANG="English" ;;
    vi)    COMMENT_LANG="Vietnamese"; UI_STRING_LANG="Vietnamese" ;;
    *)     COMMENT_LANG="$LANG_CONVENTION"; UI_STRING_LANG="$LANG_CONVENTION" ;;
  esac
}

# ── Main ──────────────────────────────────────────────────────
main() {
  print_banner
  check_existing_files
  fill_missing
  resolve_lang_convention
  validate
  print_summary

  echo -e "  ${BOLD}Generating files...${NC}"
  echo ""

  generate_agents_md
  generate_structure
  generate_quality
  generate_hooks
  generate_skills
  generate_docker
  generate_ci
  generate_docs
  run_symlinks
  install_hooks

  echo ""
  print_next_steps
}

main "$@"
