#!/usr/bin/env bash
# ============================================================
# export-pdf.sh — Frontend Reports
#
# Export a scrollable HTML report to PDF using Chromium's print
# engine (vector text, selectable, small file size).
#
#   bash scripts/export-pdf.sh <report.html> [output.pdf] [--letter|--a4]
#
# The report's own @media print rules control pagination, so keep
# report-base.css intact.
# ============================================================
set -euo pipefail

INPUT="${1:-}"
if [[ -z "$INPUT" ]]; then
  echo "usage: bash export-pdf.sh <report.html> [output.pdf] [--letter|--a4]" >&2
  exit 1
fi
if [[ ! -f "$INPUT" ]]; then
  echo "error: no such file: $INPUT" >&2
  exit 1
fi

OUTPUT=""
PAPER="letter"
shift
for arg in "$@"; do
  case "$arg" in
    --letter) PAPER="letter" ;;
    --a4)     PAPER="a4" ;;
    -*)       echo "error: unknown flag: $arg" >&2; exit 1 ;;
    *)        OUTPUT="$arg" ;;
  esac
done

INPUT_ABS="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
SERVE_DIR="$(dirname "$INPUT_ABS")"
FILE_NAME="$(basename "$INPUT_ABS")"
[[ -z "$OUTPUT" ]] && OUTPUT="${INPUT_ABS%.*}.pdf"
mkdir -p "$(dirname "$OUTPUT")"
OUTPUT_ABS="$(cd "$(dirname "$OUTPUT")" && pwd)/$(basename "$OUTPUT")"

command -v node >/dev/null 2>&1 || { echo "error: node is required. Install Node.js from https://nodejs.org" >&2; exit 1; }

# --- Playwright (cached between runs so Chromium downloads only once) ---
CACHE="${TMPDIR:-/tmp}/frontend-report-export"
mkdir -p "$CACHE"
if [[ ! -d "$CACHE/node_modules/playwright" ]]; then
  echo "Installing Playwright (first run only, this may take 30-60s)..."
  ( cd "$CACHE" && npm init -y >/dev/null 2>&1 && npm install --silent playwright >/dev/null )
fi
export NODE_PATH="$CACHE/node_modules"
if [[ -z "${PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD:-}" ]]; then
  ( cd "$CACHE" && NODE_PATH="$CACHE/node_modules" npx --no-install playwright install chromium >/dev/null 2>&1 ) || true
fi

# --- Serve the report directory so relative assets and web fonts resolve ---
URL="file://$INPUT_ABS"
SERVER_PID=""
if command -v python3 >/dev/null 2>&1; then
  PORT="$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')"
  python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$SERVE_DIR" >/dev/null 2>&1 &
  SERVER_PID=$!
  trap '[[ -n "$SERVER_PID" ]] && kill "$SERVER_PID" 2>/dev/null || true' EXIT
  python3 - "$PORT" <<'PYWAIT'
import sys, time, urllib.request
port = sys.argv[1]
for _ in range(50):
    try:
        urllib.request.urlopen(f"http://127.0.0.1:{port}/", timeout=0.5)
        break
    except Exception:
        time.sleep(0.1)
PYWAIT
  URL="http://127.0.0.1:$PORT/$FILE_NAME"
fi

echo "Rendering $FILE_NAME -> $(basename "$OUTPUT_ABS") ($PAPER)"

REPORT_URL="$URL" REPORT_OUT="$OUTPUT_ABS" REPORT_PAPER="$PAPER" node <<'NODEJS'
const { chromium } = require('playwright');

(async () => {
  const url    = process.env.REPORT_URL;
  const out    = process.env.REPORT_OUT;
  const paper  = process.env.REPORT_PAPER === 'a4' ? 'A4' : 'Letter';

  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1100, height: 1400 } });

  const errors = [];
  page.on('pageerror', e => errors.push(e.message));

  await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 });

  // Web fonts must be ready or the PDF falls back to a default face.
  await page.evaluate(() => document.fonts && document.fonts.ready);

  // A silently chart-less PDF is worse than a failed export — say so.
  const charts = await page.evaluate(() => ({
    canvases: document.querySelectorAll('canvas').length,
    loaded: typeof window.Chart !== 'undefined',
  }));
  if (charts.canvases > 0 && !charts.loaded) {
    console.error(`warning: ${charts.canvases} chart canvas(es) found but Chart.js did not load.`);
    console.error('         Charts will be BLANK in the PDF. Check network access to');
    console.error('         https://cdn.jsdelivr.net, then re-run.');
  }

  // Chart.js draws to <canvas> after load; give animations time to settle,
  // then force any remaining chart animation to its final frame.
  await page.evaluate(() => {
    if (window.Chart && window.Chart.instances) {
      Object.values(window.Chart.instances).forEach(c => { try { c.options.animation = false; c.update('none'); } catch (e) {} });
    }
  });
  await page.waitForTimeout(900);

  // Charts are sized against the print viewport, so resize before printing.
  await page.emulateMedia({ media: 'print' });
  await page.waitForTimeout(400);
  await page.evaluate(() => {
    if (window.Chart && window.Chart.instances) {
      Object.values(window.Chart.instances).forEach(c => { try { c.resize(); } catch (e) {} });
    }
  });
  await page.waitForTimeout(300);

  await page.pdf({
    path: out,
    format: paper,
    printBackground: true,
    preferCSSPageSize: true,
  });

  await browser.close();
  if (errors.length) {
    console.error('Page errors during render (PDF still written):');
    errors.slice(0, 5).forEach(e => console.error('  ' + e));
  }
})().catch(err => { console.error(err); process.exit(1); });
NODEJS

SIZE="$(du -h "$OUTPUT_ABS" | cut -f1)"
echo "Done: $OUTPUT_ABS ($SIZE)"

# Open it for the user where a handler exists.
if   command -v open    >/dev/null 2>&1; then open "$OUTPUT_ABS" || true
elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$OUTPUT_ABS" >/dev/null 2>&1 || true
fi
