---
name: frontend-reports
description: Create minimal, polished, customer-facing HTML reports with clear charts and tables. Use when the user wants a red teaming report, dataset report, model system card, evaluation summary, audit report, or any scrollable technical document meant for external sharing — not a slide deck.
---

# Frontend Reports

Create zero-build, single-file HTML reports for customer-facing technical documentation. Scrollable documents — not slide decks.

## Core Principles

1. **Minimal by default** — No decorative design. Clarity beats aesthetics. If an element does not aid comprehension, remove it.
2. **Single HTML file** — Inline CSS/JS. Charts via Chart.js CDN only. No npm or build tools.
3. **Data-first** — Tables, metrics, and charts carry the story. Prose explains; data proves.
4. **Print-ready** — Reports must look correct in browser and when exported to PDF.
5. **Accessible** — Sufficient contrast, labeled charts, semantic HTML, `prefers-reduced-motion` respected.

## Slides vs Reports

| | frontend-slides | frontend-reports |
| --- | --- | --- |
| Layout | Fixed 1920×1080 stage | Scrollable document, max-width ~900px |
| Design | Distinctive, expressive | Minimal, neutral, no frills |
| Motion | Animations encouraged | None or subtle fade-in only |
| Style discovery | 3 visual previews | Fixed system — pick report type only |
| Charts | Rare / decorative | First-class, always labeled |
| Density | One idea per slide | Sections flow naturally; paginate for PDF |

Do not apply slide-stage rules (`viewport-base.css`, `.slide`, 16:9) to reports.

---

## Phase 0: Detect Mode

- **Mode A: New report** — Go to Phase 1.
- **Mode B: Enhancement** — Read existing HTML, preserve structure and tone, improve clarity/data viz. Verify print layout after changes.
- **Mode C: Data import** — User provides CSV/JSON/notebook output. Parse data first, then Phase 1.

---

## Phase 1: Content Discovery

Ask all questions together (use structured questions when available):

**Question 1 — Report type** (header: "Type"):
- Red team / security assessment
- Dataset documentation
- Model system card
- Evaluation / benchmark summary
- Custom (user describes)

**Question 2 — Audience** (header: "Audience"):
- Executive (high-level, minimal jargon)
- Technical customer (full detail)
- Mixed (executive summary + technical appendix)

**Question 3 — Content readiness** (header: "Content"):
- All content and data ready
- Rough notes / partial data
- Outline only

**Question 4 — Branding** (header: "Branding"):
- Neutral (default — no logo, no accent color)
- Client logo + org name only
- Custom accent color (single hex)

If content or data files exist, ask the user to share them. For CSV/JSON, inspect columns and suggest relevant charts before generating.

Read [report-types.md](report-types.md) for section templates matching the chosen type.

---

## Phase 2: Outline Confirmation

Before generating, present a section outline:

1. Title block (title, date, version, author/org)
2. Executive summary (if audience is executive or mixed)
3. Type-specific sections from `report-types.md`
4. Figures/charts planned (name each chart and its data source)
5. Appendix items (if any)

Ask: "Does this structure look right?" Options: Looks good / Adjust sections / Adjust charts.

Do not run style previews. Reports use the fixed minimal system in [report-base.css](report-base.css).

---

## Phase 3: Generate Report

**Before generating, read:**

- [report-base.css](report-base.css) — Include full contents in `<style>`
- [html-template.md](html-template.md) — Document architecture
- [charts.md](charts.md) — Chart.js patterns (read only if report has charts)
- [report-types.md](report-types.md) — Section structure for chosen type

### Generation rules

**Typography & layout:**
- Body: 16–17px, line-height 1.6
- Headings: clear hierarchy (`h1` once, `h2` sections, `h3` subsections)
- Max content width: 900px centered, 48px horizontal padding
- Section spacing: 48–64px between major sections

**Color:**
- Default palette: near-black text `#1a1a1a`, muted secondary `#5c5c5c`, borders `#e5e5e5`, background `#ffffff`
- One accent for links and chart highlights only — default `#2563eb`
- Never use gradients, shadows for decoration, or colored section backgrounds

**Tables:**
- Full width, zebra optional, header row with bottom border
- Right-align numbers, left-align text
- Include units in headers where applicable

**Metrics / KPI row:**
- Use `.metric-grid` — 2–4 key numbers with label + value + optional delta
- Large number, small caption. No icons or cards with shadows.

**Charts (Chart.js via CDN):**
- Every chart needs: title, axis labels, legend (if multi-series), source note
- Prefer bar, line, and horizontal bar for comparisons; doughnut only for ≤5 categories
- Use colorblind-safe palette from `charts.md`
- Set `maintainAspectRatio: false` with fixed container height (280–360px)
- Embed data inline in `<script>` — no external data files unless user provides them

**Severity / status badges:**
- Use `.badge` with semantic classes: `.critical`, `.high`, `.medium`, `.low`, `.info`, `.pass`, `.fail`
- Text label always present — never color alone

**What to avoid:**
- Hero banners, stock imagery, decorative icons
- Slide-like full-viewport sections
- Animation beyond optional 200ms fade-in on load
- Marketing language or filler prose
- Charts without axis labels or unexplained acronyms

### Comments

Add section comments in HTML: `<!-- === SECTION: Findings === -->`

---

## Phase 4: Delivery

1. Open report: `open [filename].html`
2. Summarize for the user:
   - File path, report type, section count, chart count
   - Print/export: Cmd+P → Save as PDF, or use export script
   - Edit: inline text editing not included by default; edit HTML directly or ask for revisions

3. Ask: "Would you like a PDF export or a shareable URL?"
   - **PDF** → `bash scripts/export-pdf.sh <path-to-html> [output.pdf]`
   - **Deploy** → `bash scripts/deploy.sh <path-to-html-or-folder>`
   - Reuse deploy guidance from frontend-slides skill if user needs Vercel login help

---

## Phase 5: Quality Check

Before delivery, verify:

- [ ] Title and metadata complete
- [ ] Executive summary matches body (if present)
- [ ] Every chart has title, labels, and readable legend
- [ ] Tables don't overflow horizontally (use `.table-wrap`)
- [ ] No placeholder/lorem text
- [ ] Print preview looks correct (page breaks sensible, charts not clipped)
- [ ] Acronyms defined on first use

---

## Supporting Files

| File | Purpose | When to Read |
| --- | --- | --- |
| [report-base.css](report-base.css) | Mandatory layout and typography | Phase 3 |
| [html-template.md](html-template.md) | HTML document structure | Phase 3 |
| [report-types.md](report-types.md) | Section templates by report type | Phase 1–2 |
| [charts.md](charts.md) | Chart.js configs and palettes | Phase 3 (if charts) |
| [scripts/export-pdf.sh](scripts/export-pdf.sh) | Export scrollable report to PDF | Phase 4 |
| [scripts/deploy.sh](scripts/deploy.sh) | Deploy to Vercel | Phase 4 |
