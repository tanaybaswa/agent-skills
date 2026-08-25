#!/usr/bin/env bash
# ============================================================
# deploy.sh — deploy a report or presentation to Vercel
#
#   bash scripts/deploy.sh <file.html|folder>
#
# Accepts either a folder containing index.html, or a single HTML
# file (its locally referenced assets are bundled automatically).
# Re-running on the same input updates the SAME URL.
# ============================================================
set -euo pipefail

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  echo "usage: bash deploy.sh <file.html|folder>" >&2
  exit 1
fi
if [[ ! -e "$TARGET" ]]; then
  echo "error: no such file or directory: $TARGET" >&2
  exit 1
fi

command -v node >/dev/null 2>&1 || { echo "error: node is required. Install Node.js from https://nodejs.org" >&2; exit 1; }

# --- Auth check: give the user actionable steps rather than a raw CLI error ---
if ! npx --yes vercel whoami >/dev/null 2>&1; then
  cat >&2 <<'MSG'
error: not logged in to Vercel.

Vercel is a free hosting service. To deploy:
  1. Create an account at https://vercel.com/signup (GitHub, Google, or email)
  2. Run: npx vercel login
  3. Confirm with: npx vercel whoami
Then re-run this script.
MSG
  exit 1
fi

if [[ -d "$TARGET" ]]; then
  # --- Folder deployment: most reliable when assets sit alongside the HTML ---
  DEPLOY_DIR="$(cd "$TARGET" && pwd)"
  PROJECT_NAME="$(basename "$DEPLOY_DIR")"
  if [[ ! -f "$DEPLOY_DIR/index.html" ]]; then
    HTML_COUNT="$(find "$DEPLOY_DIR" -maxdepth 1 -name '*.html' | wc -l | tr -d ' ')"
    if [[ "$HTML_COUNT" == "1" ]]; then
      SRC="$(find "$DEPLOY_DIR" -maxdepth 1 -name '*.html')"
      echo "note: no index.html found; copying $(basename "$SRC") to index.html"
      cp "$SRC" "$DEPLOY_DIR/index.html"
    else
      echo "error: $DEPLOY_DIR has no index.html and more than one HTML file." >&2
      exit 1
    fi
  fi
  CLEANUP=""
else
  # --- Single file: stage it as index.html plus every local asset it references ---
  SRC_ABS="$(cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")"
  SRC_DIR="$(dirname "$SRC_ABS")"
  PROJECT_NAME="$(basename "${SRC_ABS%.*}" | tr '[:upper:] ._' '[:lower:]---' | sed 's/[^a-z0-9-]//g; s/--*/-/g; s/^-//; s/-$//')"
  [[ -z "$PROJECT_NAME" ]] && PROJECT_NAME="presentation"
  DEPLOY_DIR="$(mktemp -d)"
  CLEANUP="$DEPLOY_DIR"
  cp "$SRC_ABS" "$DEPLOY_DIR/index.html"

  # Collect local refs from src="", href="", poster="" and CSS url(...).
  # Remote URLs, data: URIs and anchors are skipped.
  ASSETS="$(python3 - "$SRC_ABS" <<'PY' 2>/dev/null || true
import re, sys, os
html = open(sys.argv[1], encoding='utf-8', errors='ignore').read()
refs = set()
for pat in (r'(?:src|href|poster)\s*=\s*["\']([^"\']+)["\']', r'url\(\s*["\']?([^"\')]+)["\']?\s*\)'):
    refs.update(re.findall(pat, html))
for r in sorted(refs):
    r = r.split('?')[0].split('#')[0].strip()
    if not r or r.startswith(('http://', 'https://', '//', 'data:', 'mailto:', '#', '/')):
        continue
    print(r)
PY
)"
  if [[ -n "$ASSETS" ]]; then
    while IFS= read -r rel; do
      [[ -z "$rel" ]] && continue
      if [[ -f "$SRC_DIR/$rel" ]]; then
        mkdir -p "$DEPLOY_DIR/$(dirname "$rel")"
        cp "$SRC_DIR/$rel" "$DEPLOY_DIR/$rel"
        echo "  bundled: $rel"
      fi
    done <<< "$ASSETS"
  fi
fi

echo "Deploying $PROJECT_NAME ..."
OUT="$(cd "$DEPLOY_DIR" && npx --yes vercel deploy --prod --yes --name "$PROJECT_NAME" 2>&1)" || {
  echo "$OUT" >&2
  [[ -n "$CLEANUP" ]] && rm -rf "$CLEANUP"
  exit 1
}

URL="$(echo "$OUT" | grep -Eo 'https://[a-zA-Z0-9._/-]+' | tail -1)"
[[ -n "$CLEANUP" ]] && rm -rf "$CLEANUP"

echo
echo "Live at: $URL"
echo "Works on any device. Re-running this script updates the same URL."
echo "To take it down: https://vercel.com/dashboard -> select the project -> Settings -> Delete"
echo
echo "Verify images load at the URL above. If any are broken, put the HTML and its"
echo "assets in one folder and deploy the folder instead."
