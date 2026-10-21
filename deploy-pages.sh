#!/usr/bin/env bash
# Publishes this folder to GitHub Pages (public HTTPS URL for Genesys scripts).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

GH="${GH:-gh}"
if ! command -v "$GH" >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install: brew install gh"
  exit 1
fi

if ! "$GH" auth status >/dev/null 2>&1; then
  echo "Sign in to GitHub (browser will open)…"
  "$GH" auth login -h github.com -p https -w -s repo
fi

REPO_NAME="${REPO_NAME:-cms-marketplace-agent-desktop-demo}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init -b main
fi

git add index.html
if git diff --cached --quiet; then
  echo "No changes to commit."
else
  git commit -m "Update Marketplace agent desktop demo page"
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  "$GH" repo create "$REPO_NAME" --public --source=. --remote=origin --push
else
  git push -u origin main
fi

OWNER="$("$GH" repo view --json owner -q .owner.login)"
"$GH" api "repos/${OWNER}/${REPO_NAME}/pages" -X POST \
  -f build_type=legacy \
  -f source[branch]=main \
  -f source[path]=/ 2>/dev/null || true

echo ""
echo "Public URL (may take 1–2 minutes after first publish):"
echo "  https://${OWNER}.github.io/${REPO_NAME}/"
echo ""
echo "Genesys script example:"
echo "  https://${OWNER}.github.io/${REPO_NAME}/index.html"
