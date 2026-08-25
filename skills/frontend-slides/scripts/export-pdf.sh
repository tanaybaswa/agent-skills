#!/usr/bin/env bash
# ============================================================
# export-pdf.sh — Frontend Slides
#
# Capture every slide at full stage size and combine them into a
# single landscape PDF.
#
#   bash scripts/export-pdf.sh <deck.html> [output.pdf] [--compact]
#
#   --compact   render at 1280x720 instead of 1920x1080
#               (50-70% smaller file, minimal visual difference)
#
# Animations are not preserved — each slide is captured in its
# final visual state. Slides are found via `.slide`.
# ============================================================
set -euo pipefail

INPUT="${1:-}"
if [[ -z "$INPUT" ]]; then
  echo "usage: bash export-pdf.sh <deck.html> [output.pdf] [--compact]" >&2
  exit 1
fi
if [[ ! -f "$INPUT" ]]; then
  echo "error: no such file: $INPUT" >&2
  exit 1
fi

OUTPUT=""
WIDTH=1920
HEIGHT=1080
shift
for arg in "$@"; do
  case "$arg" in
    --compact) WIDTH=1280; HEIGHT=720 ;;
    -*)        echo "error: unknown flag: $arg" >&2; exit 1 ;;
    *)         OUTPUT="$arg" ;;
  esac
done

INPUT_ABS="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
DECK_DIR="$(dirname "$INPUT_ABS")"
FILE_NAME="$(basename "$INPUT_ABS")"
[[ -z "$OUTPUT" ]] && OUTPUT="${INPUT_ABS%.*}.pdf"
mkdir -p "$(dirname "$OUTPUT")"
OUTPUT_ABS="$(cd "$(dirname "$OUTPUT")" && pwd)/$(basename "$OUTPUT")"

command -v node    >/dev/null 2>&1 || { echo "error: node is required. Install Node.js from https://nodejs.org" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "error: python3 is required (used to serve the deck locally)." >&2; exit 1; }

# --- Playwright (cached between runs so Chromium downloads only once) ---
CACHE="${TMPDIR:-/tmp}/frontend-slides-export"
mkdir -p "$CACHE"
if [[ ! -d "$CACHE/node_modules/playwright" ]]; then
  echo "Installing Playwright (first run only, this may take 30-60s)..."
  ( cd "$CACHE" && npm init -y >/dev/null 2>&1 && npm install --silent playwright >/dev/null )
fi
export NODE_PATH="$CACHE/node_modules"
if [[ -z "${PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD:-}" ]]; then
  ( cd "$CACHE" && NODE_PATH="$CACHE/node_modules" npx --no-install playwright install chromium >/dev/null 2>&1 ) || true
fi

SHOT_DIR="$(mktemp -d)"
PID_DECK=""; PID_SHOT=""
cleanup() {
  [[ -n "$PID_DECK" ]] && kill "$PID_DECK" 2>/dev/null || true
  [[ -n "$PID_SHOT" ]] && kill "$PID_SHOT" 2>/dev/null || true
  rm -rf "$SHOT_DIR"
}
trap cleanup EXIT

free_port() { python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()'; }
wait_for() {
  python3 - "$1" <<'PYWAIT'
import sys, time, urllib.request
port = sys.argv[1]
for _ in range(60):
    try:
        urllib.request.urlopen(f"http://127.0.0.1:{port}/", timeout=0.5); break
    except Exception:
        time.sleep(0.1)
PYWAIT
}

# Serving the deck over HTTP keeps relative image paths and web fonts working.
PORT_DECK="$(free_port)"
python3 -m http.server "$PORT_DECK" --bind 127.0.0.1 --directory "$DECK_DIR" >/dev/null 2>&1 &
PID_DECK=$!
wait_for "$PORT_DECK"

# A second server exposes the captured frames to the PDF assembly page,
# so nothing is written into the user's deck folder.
PORT_SHOT="$(free_port)"
python3 -m http.server "$PORT_SHOT" --bind 127.0.0.1 --directory "$SHOT_DIR" >/dev/null 2>&1 &
PID_SHOT=$!
wait_for "$PORT_SHOT"

echo "Capturing $FILE_NAME at ${WIDTH}x${HEIGHT}..."

DECK_URL="http://127.0.0.1:$PORT_DECK/$FILE_NAME" \
SHOT_DIR="$SHOT_DIR" \
SHOT_URL="http://127.0.0.1:$PORT_SHOT" \
OUT_PDF="$OUTPUT_ABS" \
W="$WIDTH" H="$HEIGHT" \
node <<'NODEJS'
const { chromium } = require('playwright');
const path = require('path');

(async () => {
  const W = parseInt(process.env.W, 10);
  const H = parseInt(process.env.H, 10);

  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });
  await page.goto(process.env.DECK_URL, { waitUntil: 'networkidle', timeout: 60000 });
  await page.evaluate(() => document.fonts && document.fonts.ready);

  const count = await page.evaluate(() => document.querySelectorAll('.slide').length);
  if (!count) {
    console.error('error: 0 slides found. This script locates slides via `.slide`.');
    console.error('       If the deck uses another class name, rename it or export manually.');
    await browser.close();
    process.exit(1);
  }

  // Freeze motion so every slide is captured in its final state.
  await page.evaluate(() => document.body.classList.add('exporting'));
  await page.addStyleTag({ content: `
    *, *::before, *::after { animation: none !important; transition: none !important; }
    .reveal { opacity: 1 !important; transform: none !important; }
    .deck-nav, .edit-handle, .edit-banner { display: none !important; }
  `});
  await page.waitForTimeout(300);

  process.stdout.write(`Found ${count} slides: `);
  for (let i = 0; i < count; i++) {
    await page.evaluate((idx) => {
      // Prefer the deck's own controller so counters and progress stay in sync.
      if (typeof window.__deckGoTo === 'function') { window.__deckGoTo(idx); return; }
      document.querySelectorAll('.slide').forEach((s, n) => s.classList.toggle('active', n === idx));
    }, i);
    await page.waitForTimeout(220);
    await page.screenshot({
      path: path.join(process.env.SHOT_DIR, `slide-${String(i + 1).padStart(3, '0')}.png`),
      clip: { x: 0, y: 0, width: W, height: H },
    });
    process.stdout.write('.');
  }
  process.stdout.write('\n');

  // Assemble: one full-bleed image per PDF page, vector-free but pixel-faithful.
  const imgs = Array.from({ length: count }, (_, i) =>
    `<img src="${process.env.SHOT_URL}/slide-${String(i + 1).padStart(3, '0')}.png">`).join('\n');

  const assembly = await browser.newPage({ viewport: { width: W, height: H } });
  await assembly.setContent(`<!DOCTYPE html><html><head><style>
    @page { size: ${W}px ${H}px; margin: 0; }
    html, body { margin: 0; padding: 0; background: #fff; }
    img { display: block; width: ${W}px; height: ${H}px; break-after: page; page-break-after: always; }
    img:last-child { break-after: auto; page-break-after: auto; }
  </style></head><body>${imgs}</body></html>`, { waitUntil: 'networkidle' });

  await assembly.pdf({
    path: process.env.OUT_PDF,
    width: `${W}px`,
    height: `${H}px`,
    printBackground: true,
    pageRanges: `1-${count}`,
  });

  await browser.close();
})().catch(err => { console.error(err); process.exit(1); });
NODEJS

SIZE_BYTES="$(wc -c < "$OUTPUT_ABS" | tr -d ' ')"
SIZE="$(du -h "$OUTPUT_ABS" | cut -f1)"
echo "Done: $OUTPUT_ABS ($SIZE)"
if [[ "$SIZE_BYTES" -gt 10485760 && "$WIDTH" -eq 1920 ]]; then
  echo
  echo "Note: this PDF is over 10MB. Re-run with --compact for a 50-70% smaller file."
fi

if   command -v open     >/dev/null 2>&1; then open "$OUTPUT_ABS" || true
elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$OUTPUT_ABS" >/dev/null 2>&1 || true
fi
