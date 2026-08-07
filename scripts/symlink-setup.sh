#!/bin/bash
# Symlink Setup: Create IDE-specific files from a single AGENTS.md
#
# Usage: ./scripts/symlink-setup.sh [tool ...]
#   No args        → set up all 10 supported tools (back-compat default)
#   One or more of  → cursor windsurf claude-code cline gemini-cli
#                     github-copilot zed codex aider continue
#
# Example: ./scripts/symlink-setup.sh claude-code cursor
#
# Fans AGENTS.md out to every supported AI IDE's native config format.
# Run this in your PROJECT ROOT (where AGENTS.md lives). This script only
# ever READS AGENTS.md — it never regenerates it from VibeCraft's own
# templates/rules/*.md, so it is safe (and expected) to re-run after
# hand-editing AGENTS.md to resync every fan-out copy.
#
# Extended by VibeCraft from obviousworks/vibe-coding-ai-rules to add:
#   - Per-tool selection (only set up the tool(s) your team actually uses,
#     instead of always generating all 10 — see plans/02-agents-md-and-ai-rules.md)
#   - Zed (.rules)
#   - Fallback to plain copy when symlinks are unsupported (e.g. Windows
#     without Developer Mode / admin rights)
#   - "Deep" multi-file rule packs for tools that support glob-scoped or
#     topic-scoped rules, instead of one flat file everywhere:
#       Cursor         → .cursor/rules/*.mdc      (glob + alwaysApply frontmatter)
#       GitHub Copilot → .github/instructions/*.instructions.md (applyTo frontmatter)
#       Cline          → .clinerules/*.md          (topic-scoped, optional globs)
#       Claude Code    → .claude/rules/*.md         (topic-scoped, no frontmatter)
#       Continue       → .continue/rules/*.md       (bucketed by topic)
#     Windsurf, Gemini CLI, Zed only support a single flat file — kept as a
#     plain symlink/copy. Codex and Aider read AGENTS.md natively — no file.
#   - Marker-based section splitting instead of heading-text matching: every
#     `## N. Title` in AGENTS.md is preceded by an HTML-comment marker
#     `<!-- vibecraft:section slug="..." cursor_globs="..." ... -->` written
#     by `init.sh`'s `generate_agents_md()`. Splitting keys off the `slug`
#     attribute, not the (renameable) heading text, so a section survives a
#     hand-edited title, and a brand-new topic added later needs no new
#     per-tool code — it's picked up generically by every "deep" generator.

set -e

if [ ! -f "AGENTS.md" ]; then
    echo "Error: AGENTS.md not found in current directory."
    echo "Please create AGENTS.md first, then run this script."
    echo ""
    echo "Quick start:"
    echo "  cp path/to/vibe-coding-ai-rules/templates/agent-template.md AGENTS.md"
    echo "  # Edit AGENTS.md for your project"
    echo "  ./scripts/symlink-setup.sh"
    exit 1
fi

ALL_TOOLS="cursor windsurf claude-code cline gemini-cli github-copilot zed codex aider continue"
TOOLS="${*:-$ALL_TOOLS}"

wants() {
  # wants <tool> — true if $1 is in the requested tool list
  case " $TOOLS " in
    *" $1 "*) return 0 ;;
    *) return 1 ;;
  esac
}

echo "Setting up AI rules from AGENTS.md for: $TOOLS"
echo ""

# ── link_or_copy <target> <source_rel> ─────────────────────────────────────
# Tries a symlink first, then VERIFIES the result is actually a symlink
# (`[ -L ]`) rather than trusting `ln`'s exit code. This matters on Windows:
# Git Bash/MSYS `ln -sf` can return exit 0 while silently writing a plain
# file copy instead of a real symlink when the process lacks symlink
# privilege (no admin / Developer Mode) — trusting the exit code alone
# reports "symlink" for files that are actually already-stale copies.
link_or_copy() {
  local target="$1"
  local source_rel="$2"   # AGENTS.md path relative to $target's directory

  mkdir -p "$(dirname "$target")"
  rm -f "$target"
  ln -sf "$source_rel" "$target" 2>/dev/null || true

  if [ -L "$target" ]; then
    echo "  ✓ $target → AGENTS.md (symlink)"
  else
    cp AGENTS.md "$target"
    echo "  ⚠ $target copied (symlink not supported here) — re-run this script after editing AGENTS.md to resync"
  fi
}

# ── extract_sections <outdir> ───────────────────────────────────────────────
# Splits AGENTS.md into one <slug>.md (body) + <slug>.attrs (per-tool hint
# fields) per `<!-- vibecraft:section slug="..." ... --> ... <!--
# vibecraft:endsection -->` block. Any content outside a marked section
# (the banner, Project Overview, the closing "Maintained by" line) is
# simply not captured — it's metadata, not a rule, and none of the "deep"
# tools need it split out on its own.
extract_sections() {
  local outdir="$1"
  mkdir -p "$outdir"
  rm -f "$outdir"/*.md "$outdir"/*.attrs

  local line slug="" cursor_globs="" copilot_apply_to="" cline_globs="" in_section=false

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      '<!-- vibecraft:section '*)
        in_section=true
        slug=$(printf '%s' "$line"      | sed -E 's/.*slug="([^"]*)".*/\1/')
        cursor_globs=$(printf '%s' "$line"      | sed -E 's/.*cursor_globs="([^"]*)".*/\1/')
        copilot_apply_to=$(printf '%s' "$line"  | sed -E 's/.*copilot_apply_to="([^"]*)".*/\1/')
        cline_globs=$(printf '%s' "$line"       | sed -E 's/.*cline_globs="([^"]*)".*/\1/')
        : > "$outdir/$slug.md"
        {
          echo "cursor_globs=$cursor_globs"
          echo "copilot_apply_to=$copilot_apply_to"
          echo "cline_globs=$cline_globs"
        } > "$outdir/$slug.attrs"
        continue
        ;;
      '<!-- vibecraft:endsection'*)
        in_section=false
        slug=""
        continue
        ;;
    esac
    if [ "$in_section" = true ]; then
      printf '%s\n' "$line" >> "$outdir/$slug.md"
    fi
  done < AGENTS.md
}

# get_attr <slug> <key> <outdir> — read one field back out of <slug>.attrs
get_attr() {
  local f="$3/$1.attrs"
  [ -f "$f" ] || { echo ""; return; }
  sed -n "s/^$2=//p" "$f"
}

SECTIONS_DIR=".vibecraft-sections-tmp"
extract_sections "$SECTIONS_DIR"

# All topic slugs actually present for this project (whatever init.sh decided
# applied, via each template's `applies_to`) — deep generators loop over this.
all_slugs() {
  local f
  for f in "$SECTIONS_DIR"/*.md; do
    [ -e "$f" ] || continue
    basename "$f" .md
  done
}

# ═══════════════════════════════════════════════════════════════════════════
# Single-file tools (flat symlink/copy, no glob or topic scoping supported)
# ═══════════════════════════════════════════════════════════════════════════

wants windsurf   && link_or_copy ".windsurfrules" "AGENTS.md"
wants gemini-cli && link_or_copy "GEMINI.md" "AGENTS.md"
wants zed        && link_or_copy ".rules" "AGENTS.md"
wants codex      && echo "  ✓ Codex reads AGENTS.md natively — no file created"
wants aider      && echo "  ✓ Aider reads AGENTS.md natively — no file created"

# ═══════════════════════════════════════════════════════════════════════════
# Deep multi-file tools — every one below loops over all_slugs(), so a new
# rule topic (a new templates/rules/*.md in VibeCraft) needs no new code
# here; it just shows up next time AGENTS.md is regenerated and this script
# re-run.
# ═══════════════════════════════════════════════════════════════════════════

# ── Cursor: .cursor/rules/*.mdc (YAML frontmatter: globs, alwaysApply) ─────
generate_cursor_rules() {
  local dir=".cursor/rules"
  mkdir -p "$dir"
  rm -f "$dir"/*.mdc

  local slug globs always
  for slug in $(all_slugs); do
    globs=$(get_attr "$slug" cursor_globs "$SECTIONS_DIR")
    always=true
    [ -n "$globs" ] && always=false
    {
      echo "---"
      [ -n "$globs" ] && echo "globs: \"$globs\""
      echo "alwaysApply: $always"
      echo "---"
      echo ""
      cat "$SECTIONS_DIR/$slug.md"
    } > "$dir/$slug.mdc"
  done

  echo "  ✓ .cursor/rules/*.mdc (glob-scoped rule pack)"
}
wants cursor && generate_cursor_rules

# ── GitHub Copilot: main file + .github/instructions/*.instructions.md ────
generate_copilot_instructions() {
  link_or_copy ".github/copilot-instructions.md" "../AGENTS.md"

  local dir=".github/instructions"
  mkdir -p "$dir"
  rm -f "$dir"/*.instructions.md

  local slug apply
  for slug in $(all_slugs); do
    apply=$(get_attr "$slug" copilot_apply_to "$SECTIONS_DIR")
    {
      echo "---"
      [ -n "$apply" ] && echo "applyTo: \"$apply\""
      echo "---"
      echo ""
      cat "$SECTIONS_DIR/$slug.md"
    } > "$dir/$slug.instructions.md"
  done

  echo "  ✓ .github/instructions/*.instructions.md (applyTo-scoped rule pack)"
}
wants github-copilot && generate_copilot_instructions

# ── Cline: .clinerules/*.md (topic-scoped, optional globs frontmatter) ────
generate_cline_rules() {
  local dir=".clinerules"
  # .clinerules may currently be a single FILE (from an older run / manual
  # setup) — remove it first so mkdir -p for the folder form doesn't fail.
  [ -f "$dir" ] && rm -f "$dir"
  mkdir -p "$dir"
  rm -f "$dir"/*.md

  local slug globs
  for slug in $(all_slugs); do
    globs=$(get_attr "$slug" cline_globs "$SECTIONS_DIR")
    if [ -n "$globs" ]; then
      { echo "---"; echo "globs: \"$globs\""; echo "---"; echo ""; cat "$SECTIONS_DIR/$slug.md"; } > "$dir/$slug.md"
    else
      cp "$SECTIONS_DIR/$slug.md" "$dir/$slug.md"
    fi
  done

  echo "  ✓ .clinerules/*.md (topic-scoped rule pack)"
}
wants cline && generate_cline_rules

# ── Claude Code: CLAUDE.md (main) + .claude/rules/*.md (topic-scoped) ─────
generate_claude_rules() {
  link_or_copy "CLAUDE.md" "AGENTS.md"

  local dir=".claude/rules"
  mkdir -p "$dir"
  rm -f "$dir"/*.md

  local slug
  for slug in $(all_slugs); do
    cp "$SECTIONS_DIR/$slug.md" "$dir/$slug.md"
  done

  echo "  ✓ .claude/rules/*.md (topic-scoped rule pack)"
}
wants claude-code && generate_claude_rules

# ── Continue: .continue/rules/*.md (bucketed by topic) ─────────────────────
# Continue's convention favors a handful of broad files over one-per-topic —
# unlike the other 4 deep tools, this one groups slugs into fixed buckets.
generate_continue_rules() {
  local dir=".continue/rules"
  mkdir -p "$dir"
  rm -f "$dir"/*.md

  bucket_cat() {
    local out="$dir/$1"; shift
    local s any=false
    for s in "$@"; do
      [ -f "$SECTIONS_DIR/$s.md" ] || continue
      cat "$SECTIONS_DIR/$s.md" >> "$out"
      echo "" >> "$out"
      any=true
    done
    [ "$any" = true ] || rm -f "$out"
  }

  bucket_cat "core-principles.md" architecture naming-conventions backend-mvc frontend-structure api-design
  bucket_cat "code-style.md"      code-style clean-code performance logging language
  bucket_cat "security.md"        security
  bucket_cat "testing.md"         testing code-review
  bucket_cat "workflow.md"        git-workflow ai-permissions workflow-contract

  echo "  ✓ .continue/rules/*.md (topic-bucketed rule pack)"
}
wants continue && generate_continue_rules

rm -rf "$SECTIONS_DIR"

# ═══════════════════════════════════════════════════════════════════════════
echo ""
echo "Done! AI rules set up for: $TOOLS"
echo "Edit AGENTS.md and re-run this script (with the same tool list) to resync everything."
echo ""
echo "Re-run examples:"
echo "  ./scripts/symlink-setup.sh                       # all 10 tools"
echo "  ./scripts/symlink-setup.sh claude-code cursor     # only these two"
