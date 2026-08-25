# Style Presets

Twelve curated visual systems. Each is a starting point with a committed
point of view — not a template to fill in. Adapt the palette, push the
typography, and add a device that belongs to *this* deck.

Presets are the **safe** half of the Phase 2 preview mix. At least one preview
should be bolder than anything on this page.

## Mood routing

| Mood | Suggested presets |
| --- | --- |
| Impressed / confident | Bold Signal, Electric Studio, Dark Botanical |
| Excited / energized | Creative Voltage, Neon Cyber, Split Pastel |
| Calm / focused | Notebook Tabs, Paper & Ink, Swiss Modern |
| Inspired / moved | Dark Botanical, Vintage Editorial, Pastel Geometry |
| Technical / credible | Terminal Phosphor, Swiss Modern, Bold Signal |

Vary the scheme across generations. Four presets are dark by default; every
light preset lists a dark inversion. Do not default to dark every time.

---

## 1. Bold Signal — dark

Editorial confidence. Enormous type, one violent accent, nothing else.

- **Fonts** — Clash Display 600/700 + Satoshi 400/500
  `https://api.fontshare.com/v2/css?f[]=clash-display@600,700&f[]=satoshi@400,500&display=swap`
- **Palette** — bg `#0d0e11` · ink `#f2f0ea` · muted `#8b8b95` · accent `#ff4d1c`
- **Signature** — 148px headlines at -0.03em, hairline rules, a single accent bar that grows on entry, slide numbers as oversized ghost numerals
- **Motion** — mask-wipe headlines, 90ms stagger
- **Best for** — pitch decks, keynote openers, strategy narratives
- **Avoid for** — dense data walkthroughs

## 2. Electric Studio — light

Design-agency energy. Offset colour blocks and unapologetic scale.

- **Fonts** — Cabinet Grotesk 700/800 + General Sans 400/500
  `https://api.fontshare.com/v2/css?f[]=cabinet-grotesk@700,800&f[]=general-sans@400,500&display=swap`
- **Palette** — bg `#f4f2ed` · ink `#12100e` · accent `#2b4cff` · pop `#ffe14d`
- **Signature** — colour blocks offset from their type, giant section numerals, tight 8px grid
- **Motion** — blocks slide in from opposite edges, then type settles
- **Best for** — product launches, brand work, creative reviews
- **Avoid for** — legal, medical, conservative finance
- **Dark inversion** — ink `#f4f2ed` on `#12100e`, keep both accents

## 3. Dark Botanical — dark

Quiet luxury. Deep greens, gold hairlines, breathing room.

- **Fonts** — Cormorant Garamond 300/600 + Karla 400/500
  `https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@300;600&family=Karla:wght@400;500&display=swap`
- **Palette** — bg `#10140f` · ink `#ece8dd` · muted `#7f8a78` · accent `#7c9a6d` · gold `#c9a227`
- **Signature** — layered radial gradients, thin gold rules, botanical SVG line motifs at 6% opacity, generous margins
- **Motion** — slow 900ms fades, letter-spacing settle on headlines
- **Best for** — brand storytelling, sustainability, hospitality, fundraising
- **Avoid for** — high-energy sales decks

## 4. Creative Voltage — light

Playful and loud without being childish.

- **Fonts** — Chillax 500/600 + Switzer 400/500
  `https://api.fontshare.com/v2/css?f[]=chillax@500,600&f[]=switzer@400,500&display=swap`
- **Palette** — bg `#fffdf7` · ink `#14110f` · accent `#ff2e63` · secondary `#00d0b0`
- **Signature** — rotated sticker labels, thick 6px outlines, overlapping shapes, no shadows
- **Motion** — springy overshoot on entry `cubic-bezier(0.34, 1.56, 0.64, 1)`
- **Best for** — workshops, culture decks, hackathons, internal all-hands
- **Avoid for** — board meetings, incident reviews
- **Dark inversion** — `#14110f` bg, keep the accent pair at full saturation

## 5. Neon Cyber — dark

Night-city terminal. Glow, grid, and speed.

- **Fonts** — Chakra Petch 500/700 + JetBrains Mono 400
  `https://fonts.googleapis.com/css2?family=Chakra+Petch:wght@500;700&family=JetBrains+Mono:wght@400&display=swap`
- **Palette** — bg `#05060a` · ink `#d9f2ff` · accent `#00e5ff` · hot `#ff007a`
- **Signature** — perspective grid horizon, 1px scanline overlay, text-shadow glow on headings only, mono labels in caps
- **Motion** — glitch offset on slide entry (keep it to 180ms), pulsing accent underline
- **Best for** — security, infra, gaming, developer tooling
- **Avoid for** — anything needing warmth or long reading passages

## 6. Split Pastel — light

Warm editorial calm with a structural twist.

- **Fonts** — Fraunces 400/700 (opsz on) + Switzer 400/500
  `https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,700&display=swap`
  `https://api.fontshare.com/v2/css?f[]=switzer@400,500&display=swap`
- **Palette** — bg `#f7f1ea` · ink `#2a2620` · terracotta `#e28f6b` · slate `#6b8fa3`
- **Signature** — diagonal or 40/60 split panels, one panel always a flat colour field, oversized pull quotes
- **Motion** — panels wipe apart from the centre, content fades after
- **Best for** — research summaries, design reviews, editorial narratives
- **Avoid for** — dense tabular content

## 7. Notebook Tabs — light

Approachable teaching. Looks handmade, behaves rigorously.

- **Fonts** — Caveat 600 (accents only) + IBM Plex Sans 400/600
  `https://fonts.googleapis.com/css2?family=Caveat:wght@600&family=IBM+Plex+Sans:wght@400;600&display=swap`
- **Palette** — bg `#fdfbf4` · ink `#1f2933` · marker `#d94f30` · blue `#2f6f8f` · rule `#dfd8c8`
- **Signature** — faint ruled-paper background, tab-shaped section headers, hand-drawn SVG underlines and circles, margin annotations
- **Motion** — underlines draw with `stroke-dasharray`, annotations fade in last
- **Best for** — tutorials, onboarding, lectures, explainer decks
- **Avoid for** — executive pitches, formal client deliverables
- **Never** — use Caveat for body copy; it is an accent face only

## 8. Paper & Ink — light

Restrained literary formality. Nothing decorative survives.

- **Fonts** — Newsreader 300/600 + Archivo 400/500
  `https://fonts.googleapis.com/css2?family=Newsreader:opsz,wght@6..72,300;6..72,600&family=Archivo:wght@400;500&display=swap`
- **Palette** — bg `#f6f4ef` · ink `#1b1a17` · muted `#6d6a63` · accent `#8b1e1e`
- **Signature** — drop caps, single hairline rules, wide margins, footnote-style captions, no fills
- **Motion** — 600ms opacity only. No movement.
- **Best for** — policy, research, law, annual reviews, memorial or serious topics
- **Avoid for** — product launches
- **Dark inversion** — ink `#f2efe8` on `#17161a`, accent `#c4514f`

## 9. Swiss Modern — light

Grid discipline. The composition is the design.

- **Fonts** — Supreme 500/700 + Synonym 400/500
  `https://api.fontshare.com/v2/css?f[]=supreme@500,700&f[]=synonym@400,500&display=swap`
- **Palette** — bg `#ffffff` · ink `#111111` · grey `#767676` · accent `#e63329`
- **Signature** — visible 12-column grid, everything flush left, one red element per slide, ranged-left ragged text, huge margins
- **Motion** — content enters on the grid axis, 60ms stagger, no easing flourish
- **Best for** — consulting, architecture, enterprise, data-heavy reading decks
- **Avoid for** — emotional storytelling
- **Dark inversion** — `#111111` bg with `#f5f5f5` ink; keep the red

## 10. Vintage Editorial — light

Seventies print magazine. Warm, grainy, confidently dated.

- **Fonts** — Zodiak 500/700 + Erode 400/500
  `https://api.fontshare.com/v2/css?f[]=zodiak@500,700&f[]=erode@400,500&display=swap`
- **Palette** — bg `#efe7d8` · ink `#221d18` · rust `#b4531f` · pine `#35564b` · mustard `#d9a441`
- **Signature** — SVG grain overlay at 8%, drop caps, ornamental double rules, arched image masks, two-column body
- **Motion** — slow cross-dissolves, type rises 12px
- **Best for** — brand heritage, culture, food, publishing, retrospectives
- **Avoid for** — technical specs

## 11. Pastel Geometry — light

Optimistic product design. Flat shapes, soft palette, sharp structure.

- **Fonts** — Panchang 500/700 + Satoshi 400/500
  `https://api.fontshare.com/v2/css?f[]=panchang@500,700&f[]=satoshi@400,500&display=swap`
- **Palette** — bg `#fef6f0` · ink `#23202b` · violet `#7b6cf6` · peach `#ffb37b` · mint `#7ad9c4`
- **Signature** — arcs and half-circles bleeding off the edge, flat fills only (no shadows), rounded 24px panels, colour-coded sections
- **Motion** — shapes rotate in slowly behind content, staggered card lifts
- **Best for** — SaaS product decks, roadmaps, design systems, onboarding
- **Avoid for** — sombre subject matter

## 12. Terminal Phosphor — dark

CRT engineering log. Monospace rigour, zero decoration.

- **Fonts** — JetBrains Mono 400/700 + IBM Plex Mono 400
  `https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=IBM+Plex+Mono:wght@400&display=swap`
- **Palette** — bg `#0a0f0a` · ink `#b6ffb0` · dim `#4f7a4c` · amber `#ffb000` · alert `#ff5f56`
- **Signature** — everything on a monospace character grid, ASCII box rules (`+--+`, `|`), blinking block cursor after headlines, `[ 03 / 14 ]` slide markers, subtle phosphor bloom
- **Motion** — typewriter reveal on headlines (cap at 40ms/char), cursor blink at 1.06s
- **Best for** — red team readouts, incident reviews, systems architecture, CTF debriefs
- **Avoid for** — non-technical executive audiences, long prose
- **Never** — animate more than one typewriter line per slide

---

## Using a preset

1. Copy the palette into `:root` as CSS variables. Never hard-code a hex twice.
2. Load exactly the weights listed. Extra weights cost load time for nothing.
3. Build the signature element first — it is what makes the deck look authored.
4. Keep the accent scarce. One accent moment per slide beats five.
5. Respect the user's density choice: speaker-led decks push the type scale up
   and the word count down; reading-first decks add structure, not clutter.
