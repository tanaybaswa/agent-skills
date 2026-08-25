# Animation Patterns

CSS-first motion for fixed-stage decks. Every pattern here is inline-able,
dependency-free, and safe inside a scaled 1920x1080 stage.

## Effect → feeling

| Feeling | Reach for | Timing |
| --- | --- | --- |
| Confident, decisive | Mask wipe, accent bar growth, hard cuts | 400–600ms, `cubic-bezier(0.22, 1, 0.36, 1)` |
| Energetic, playful | Spring overshoot, rotation, pop-in | 350–500ms, `cubic-bezier(0.34, 1.56, 0.64, 1)` |
| Calm, considered | Opacity-only fades, slow letter-spacing settle | 700–1000ms, `ease-out` |
| Technical, precise | Typewriter, counter roll, line draw | linear or `steps()` |
| Cinematic, weighty | Slow scale (1.06 → 1), parallax layers, vignette bloom | 1200ms+, `ease-in-out` |

**One orchestrated entrance beats five scattered micro-interactions.** Spend the
motion budget on slide entry: a staggered reveal of 3–5 elements reads as
designed; a hover effect on every card reads as noise.

---

## The stagger (default entrance)

`viewport-base.css` already ships `.reveal` plus `.d1`–`.d8`. Use it first.

```html
<h1 class="reveal">Headline</h1>
<p  class="reveal d2">Supporting line</p>
<div class="reveal d3 from-below">…</div>
```

Set a custom delay inline when the class ladder is too coarse:

```html
<li class="reveal" style="--reveal-delay: 220ms">…</li>
```

For a list of unknown length, stagger in CSS instead of hand-numbering:

```css
.stagger > * { --reveal-delay: calc(var(--i, 0) * 80ms); }
.stagger > *:nth-child(1) { --i: 1; }
.stagger > *:nth-child(2) { --i: 2; }
/* … through the max count you actually use */
```

---

## Mask wipe headline

The workhorse for confident decks. Text rises out of an invisible slot.

```css
.mask-line { overflow: hidden; }
.mask-line > span {
  display: block;
  transform: translateY(110%);
  transition: transform 720ms cubic-bezier(0.22, 1, 0.36, 1);
  transition-delay: var(--reveal-delay, 0ms);
}
.slide.active .mask-line > span { transform: translateY(0); }
```

```html
<h1 class="mask-line"><span>Ship the thing</span></h1>
<h1 class="mask-line"><span style="--reveal-delay:120ms">Then ship it again</span></h1>
```

---

## Accent bar growth

```css
.accent-bar {
  height: 8px;
  width: 0;
  background: var(--accent);
  transition: width 640ms cubic-bezier(0.22, 1, 0.36, 1) 240ms;
}
.slide.active .accent-bar { width: 320px; }
```

Vertical variant: animate `height` with `transform-origin: top`.

---

## Typewriter

Cap at one line per slide. Any longer and the audience waits on you.

```css
.type {
  display: inline-block;
  overflow: hidden;
  white-space: nowrap;
  border-right: 3px solid var(--accent);
  width: 0;
}
.slide.active .type {
  animation:
    type-in 1600ms steps(34, end) 300ms forwards,
    caret 1060ms step-end infinite;
}
@keyframes type-in { to { width: 34ch; } }
@keyframes caret   { 50% { border-color: transparent; } }
```

Match `steps()` and the final `ch` width to the real character count.

---

## Counter roll

Numbers that count up read as evidence. JS, fired on slide entry.

```javascript
function rollCounters(slide) {
  slide.querySelectorAll('[data-count]').forEach(el => {
    const target = parseFloat(el.dataset.count);
    const decimals = (el.dataset.decimals | 0);
    const start = performance.now();
    const dur = 1100;
    (function step(now) {
      const t = Math.min((now - start) / dur, 1);
      const eased = 1 - Math.pow(1 - t, 3);          // ease-out cubic
      el.textContent = (target * eased).toFixed(decimals);
      if (t < 1) requestAnimationFrame(step);
    })(start);
  });
}
```

Call it from `goTo()` after the class swap, and guard it:

```javascript
if (!matchMedia('(prefers-reduced-motion: reduce)').matches) rollCounters(slides[current]);
```

---

## SVG line draw

For diagrams, underlines, and hand-drawn accents.

```css
.draw path {
  stroke-dasharray: var(--len, 400);
  stroke-dashoffset: var(--len, 400);
  transition: stroke-dashoffset 900ms ease-out var(--reveal-delay, 0ms);
}
.slide.active .draw path { stroke-dashoffset: 0; }
```

Set `--len` to slightly more than the real path length (`path.getTotalLength()`).

---

## Ambient background layers

Atmosphere without distraction. These loop; keep them slow and low-contrast.

```css
/* Drifting gradient field */
.bg-drift {
  position: absolute;
  inset: -20%;
  background:
    radial-gradient(50% 50% at 20% 30%, color-mix(in srgb, var(--accent) 22%, transparent), transparent 70%),
    radial-gradient(45% 45% at 80% 70%, color-mix(in srgb, var(--accent) 12%, transparent), transparent 70%);
  filter: blur(60px);
  animation: drift 26s ease-in-out infinite alternate;
  pointer-events: none;
}
@keyframes drift { to { transform: translate3d(4%, -3%, 0) scale(1.08); } }

/* Film grain — SVG noise, no image asset */
.bg-grain {
  position: absolute;
  inset: 0;
  opacity: 0.07;
  pointer-events: none;
  background-image: url("data:image/svg+xml;utf8,\
<svg xmlns='http://www.w3.org/2000/svg' width='180' height='180'>\
<filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='3'/></filter>\
<rect width='100%' height='100%' filter='url(%23n)'/></svg>");
}

/* Scanlines */
.bg-scan {
  position: absolute;
  inset: 0;
  opacity: 0.16;
  pointer-events: none;
  background: repeating-linear-gradient(
    to bottom,
    rgba(255,255,255,0.06) 0 1px,
    transparent 1px 3px
  );
}
```

Mark every ambient layer `aria-hidden="true"`.

---

## Slide transitions

The base fade is in `viewport-base.css`. Swap it per deck by overriding
`--slide-fade` and adding a directional variant:

```css
/* Push: outgoing slide drifts left, incoming enters from the right */
.slide            { transform: translateX(60px); }
.slide.active     { transform: translateX(0); transition: opacity var(--slide-fade) var(--ease), transform var(--slide-fade) var(--ease); }
```

Keep transforms small — the whole stage is already scaled, so a 60px design-space
shift reads as ~20px on a phone. Never transition `filter: blur()` on the stage
itself; it forces a full-stage repaint at every frame.

---

## Performance rules

- Animate `transform` and `opacity` only. Never `width`, `top`, `margin`, or
  `box-shadow` on anything large.
- `will-change` on at most 2–3 elements per slide, and never on `.deck-stage`.
- Ambient loops run continuously on every slide — keep them under ~3 layers.
- Test on a phone. A 60px blur over a full-bleed layer will drop frames.

## Reduced motion

`viewport-base.css` neutralises transitions and animations under
`prefers-reduced-motion: reduce` and forces `.reveal` to its final state. Any
JS-driven motion you add must check the query itself:

```javascript
const reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;
```

Reduced motion must never mean missing content — the slide still shows
everything, it just arrives without movement.
