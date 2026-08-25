# HTML Presentation Template

Reference architecture for a single-file, zero-dependency deck. Every deck is
one `.html` file: inline `<style>`, inline `<script>`, fonts from a CDN link.

## Document skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
  <title>Deck Title</title>

  <!-- Fonts: Fontshare or Google Fonts. Never system fonts. -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://api.fontshare.com/v2/css?f[]=clash-display@600,700&f[]=satoshi@400,500&display=swap" rel="stylesheet">

  <style>
    /* === PASTE FULL viewport-base.css HERE === */

    /* === THEME === */
    :root {
      --bg:      #0d0e11;
      --ink:     #f2f0ea;
      --muted:   #8b8b95;
      --accent:  #ff4d1c;
      --font-display: 'Clash Display', serif;
      --font-body:    'Satoshi', sans-serif;
    }

    /* === SLIDE LAYOUTS ===
       All measurements in fixed px at the 1920x1080 design size. */
    .slide-title h1 { font: 700 148px/0.94 var(--font-display); letter-spacing: -0.03em; }
    /* ... */
  </style>
</head>
<body>

  <div class="deck-viewport">
    <div class="deck-stage" id="stage">

      <!-- === SLIDE 1: Title === -->
      <section class="slide slide-title active" aria-label="Title">
        <div class="slide-content">
          <h1 class="reveal">Deck Title</h1>
          <p class="reveal d2">Subtitle or presenter</p>
        </div>
      </section>
      <!-- SPEAKER NOTES: open with the origin story, ~40 seconds. -->

      <!-- === SLIDE 2: Section === -->
      <section class="slide" aria-label="Section">
        <div class="slide-content">…</div>
      </section>

    </div>
  </div>

  <!-- Chrome lives OUTSIDE the stage so it never scales with it -->
  <div class="deck-progress"><div class="deck-progress-bar" id="progressBar"></div></div>
  <div class="slide-counter" id="counter">1 / 12</div>
  <nav class="deck-nav" aria-label="Slide navigation">
    <button id="prevBtn" aria-label="Previous slide">&#8592;</button>
    <button id="nextBtn" aria-label="Next slide">&#8594;</button>
  </nav>
  <div class="edit-handle" id="editHandle" title="Edit text (E)"></div>
  <div class="edit-banner">EDIT MODE &middot; click any text to edit &middot; Ctrl/Cmd+S to save &middot; Esc to exit</div>

  <script>
    /* === PASTE THE DECK CONTROLLER HERE === */
  </script>
</body>
</html>
```

Structural rules:

- One `.deck-viewport` wrapping one `.deck-stage`. Slides are direct children of the stage.
- The first slide carries `active` in the markup so the deck renders before JS runs.
- Chrome (progress bar, counter, nav, edit affordances) sits outside `.deck-viewport`.
- Speaker notes are HTML comments directly after their slide, prefixed `SPEAKER NOTES:`.

---

## Deck controller

Paste verbatim, adjusting only what a specific deck needs.

```javascript
/* === STAGE FITTING ===
   Scales the fixed 1920x1080 stage to the viewport. Uniform scale
   only — content never reflows. */
function fitStage() {
  var s = Math.min(window.innerWidth / 1920, window.innerHeight / 1080);
  document.documentElement.style.setProperty('--stage-scale', s);
}
fitStage();
addEventListener('resize', fitStage);
addEventListener('orientationchange', fitStage);

/* === DECK STATE === */
const slides   = Array.from(document.querySelectorAll('.slide'));
const bar      = document.getElementById('progressBar');
const counter  = document.getElementById('counter');
let current    = 0;

function goTo(index) {
  const next = Math.max(0, Math.min(index, slides.length - 1));
  if (next === current && slides[next].classList.contains('active')) return;

  slides.forEach((s, i) => s.classList.toggle('active', i === next));
  current = next;

  if (bar)     bar.style.width = ((current + 1) / slides.length * 100) + '%';
  if (counter) counter.textContent = (current + 1) + ' / ' + slides.length;
  history.replaceState(null, '', '#' + (current + 1));
}

const next = () => goTo(current + 1);
const prev = () => goTo(current - 1);

/* Hook used by scripts/export-pdf.sh — keep this name. */
window.__deckGoTo   = goTo;
window.__deckLength = slides.length;

/* === KEYBOARD === */
document.addEventListener('keydown', (e) => {
  if (document.body.classList.contains('editing')) {
    if (e.key === 'Escape') toggleEdit(false);
    if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 's') { e.preventDefault(); saveDeck(); }
    return;                          // never navigate while typing
  }
  switch (e.key) {
    case 'ArrowRight': case 'ArrowDown': case ' ': case 'PageDown':
      e.preventDefault(); next(); break;
    case 'ArrowLeft': case 'ArrowUp': case 'PageUp':
      e.preventDefault(); prev(); break;
    case 'Home': e.preventDefault(); goTo(0); break;
    case 'End':  e.preventDefault(); goTo(slides.length - 1); break;
    case 'f': case 'F':
      document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen();
      break;
    case 'e': case 'E': toggleEdit(true); break;
  }
});

/* === POINTER + TOUCH === */
document.getElementById('nextBtn')?.addEventListener('click', next);
document.getElementById('prevBtn')?.addEventListener('click', prev);

let touchX = null, touchY = null;
addEventListener('touchstart', (e) => {
  touchX = e.changedTouches[0].clientX;
  touchY = e.changedTouches[0].clientY;
}, { passive: true });
addEventListener('touchend', (e) => {
  if (touchX === null) return;
  const dx = e.changedTouches[0].clientX - touchX;
  const dy = e.changedTouches[0].clientY - touchY;
  if (Math.abs(dx) > 50 && Math.abs(dx) > Math.abs(dy)) { dx < 0 ? next() : prev(); }
  touchX = touchY = null;
}, { passive: true });

/* === DEEP LINK === */
const fromHash = parseInt(location.hash.slice(1), 10);
goTo(Number.isFinite(fromHash) && fromHash > 0 ? fromHash - 1 : 0);
addEventListener('hashchange', () => {
  const n = parseInt(location.hash.slice(1), 10);
  if (Number.isFinite(n)) goTo(n - 1);
});

/* === INLINE TEXT EDITING ===
   On by default. Omit only if the user asked for a locked file. */
const EDITABLE = 'h1, h2, h3, h4, h5, h6, p, li, td, th, blockquote, figcaption, .editable';

function toggleEdit(on) {
  const enable = on === undefined ? !document.body.classList.contains('editing') : on;
  document.body.classList.toggle('editing', enable);
  document.querySelectorAll(EDITABLE).forEach(el => {
    if (enable) el.setAttribute('contenteditable', 'true');
    else        el.removeAttribute('contenteditable');
  });
}
document.getElementById('editHandle')?.addEventListener('click', () => toggleEdit());

function saveDeck() {
  const clone = document.documentElement.cloneNode(true);
  clone.querySelectorAll('[contenteditable]').forEach(el => el.removeAttribute('contenteditable'));
  clone.querySelector('body')?.classList.remove('editing');
  // Persist the edited text, not the current slide position.
  clone.querySelectorAll('.slide').forEach((s, i) => s.classList.toggle('active', i === 0));

  const html = '<!DOCTYPE html>\n' + clone.outerHTML;
  const url  = URL.createObjectURL(new Blob([html], { type: 'text/html' }));
  const a    = document.createElement('a');
  a.href = url;
  a.download = (document.title || 'presentation').replace(/[^\w.-]+/g, '-') + '.html';
  a.click();
  URL.revokeObjectURL(url);
}
```

---

## Code quality standards

- **Section comments are required.** Every CSS and JS region opens with
  `/* === SECTION NAME === */`. Every slide opens with `<!-- === SLIDE n: Purpose === -->`.
- **CSS variables for every repeated value.** Colours, fonts, and spacing rhythm
  live in `:root` so the user can retheme by editing one block.
- **No frameworks, no build step, no external JS.** Fonts are the only network
  dependency; the deck must still be navigable if they fail to load.
- **Semantic HTML.** `<section class="slide">` with `aria-label`, real headings,
  real lists. Decorative shapes get `aria-hidden="true"`.
- **Optional chaining on every chrome lookup** (`document.getElementById('x')?.…`)
  so a deck that omits a control still runs.
- **Never `display:none` for slide switching.** See the note in `viewport-base.css`.

## Verification before delivery

Screenshot at 1280x720 and at one phone viewport (e.g. 390x844), then confirm:

- The stage is 16:9 and letterboxed at both sizes — never reflowed.
- No text overflows its container; no panels overlap.
- Exactly one slide is visible at a time.
- Reveals fire on slide entry and replay on return.
- `document.body.scrollHeight <= window.innerHeight` (the deck never scrolls).

`scrollHeight` alone is not sufficient — grid panels can visually cover each
other while reporting no overflow. Look at the rendered screenshots.
