#!/usr/bin/env bash
# Packages this repo into a distributable .zip for Claude Code's `archive` plugin source
# (https://code.claude.com/docs/en/plugin-marketplaces#zip-archives) — lets a user install
# vibecraft without git-cloning the repo themselves, as long as the zip (and the
# marketplace.json this script also generates) are reachable over plain HTTPS, e.g. attached
# to a GitHub Release.
#
# Uses `git archive`, not a manual copy/zip: it only ever includes committed, tracked files
# (uncommitted work-in-progress never leaks into a published archive) and needs no extra
# tooling beyond git itself — deliberate, since this machine has no `zip` binary on PATH.
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Uncommitted changes present — commit first. git archive only packages committed" >&2
  echo "content, so uncommitted edits would silently be missing from the published zip." >&2
  exit 1
fi

VERSION=$(node -p "require('./package.json').version")
REPO="${VIBECRAFT_REPO:-PVN-Organization/vibecraft}"
OUT_DIR="dist"
ZIP_NAME="vibecraft-plugin-${VERSION}.zip"

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR/$ZIP_NAME"

git archive --format=zip -o "$OUT_DIR/$ZIP_NAME" HEAD
SHA256=$(sha256sum "$OUT_DIR/$ZIP_NAME" | awk '{print $1}')

echo "Built $OUT_DIR/$ZIP_NAME"
echo "sha256: $SHA256"

# This marketplace.json is a SEPARATE file from .claude-plugin/marketplace.json — that one
# stays a relative-path ("./") source for the existing git-based install (README "Cách 4":
# `/plugin marketplace add PVN-Organization/vibecraft`), which already works and is tested.
# This one is the archive-channel manifest: point a user at this file's own URL (once
# uploaded as a Release asset) instead of the repo, and Claude Code fetches only this JSON
# plus the zip below over HTTPS — no git clone of the repo at all, not even for the catalog.
cat > "$OUT_DIR/marketplace.json" <<EOF
{
  "\$schema": "https://code.claude.com/schemas/marketplace.json",
  "name": "vibecraft-marketplace",
  "owner": { "name": "VibeCraft" },
  "description": "Self-hosted marketplace for the VibeCraft guardrails installer (archive channel — no git required)",
  "plugins": [
    {
      "name": "vibecraft",
      "description": "Install VibeCraft's production-ready guardrails into the current project",
      "version": "$VERSION",
      "source": {
        "source": "archive",
        "url": "https://github.com/$REPO/releases/download/v$VERSION/$ZIP_NAME",
        "sha256": "$SHA256"
      }
    }
  ]
}
EOF

echo "Generated $OUT_DIR/marketplace.json"
echo ""
echo "Next steps to publish v$VERSION on the archive channel:"
echo "  gh release create v$VERSION \"$OUT_DIR/$ZIP_NAME\" \"$OUT_DIR/marketplace.json\" --title \"v$VERSION\" --notes \"...\""
echo "Then users install with:"
echo "  /plugin marketplace add https://github.com/$REPO/releases/download/v$VERSION/marketplace.json"
echo "  /plugin install vibecraft@vibecraft-marketplace"
