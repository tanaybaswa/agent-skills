# agent-skills

My agent skills for Claude Code — HTML deliverables (slides, reports) and
diagramming, plus the official Azure icon set and reference architectures.

**8 active skills** in `skills/` · **7 benched** in `other_diagraming_tools/`

> **Diagrams → [`drawio-skill`](skills/drawio-skill/).** It is the one
> diagramming skill that is installed and the default for every diagram request.
> The alternatives (Mermaid, Excalidraw, PlantUML, C4) are on the
> [bench](#the-bench) — kept for reference, not active.

---

## Contents

- [Quick start](#quick-start)
- [Repository map](#repository-map)
- [Active skills](#active-skills)
- [Research pipeline](#research-pipeline)
- [The bench](#the-bench)
- [Azure assets](#azure-assets)
- [Installing](#installing)
- [Conventions](#conventions)
- [Requirements](#requirements)
- [Licensing](#licensing)

---

## Quick start

```bash
git clone https://github.com/tanaybaswa/agent-skills.git
cd agent-skills
mkdir -p ~/.claude/skills ~/.claude/agents
for s in skills/*/; do ln -sfn "$PWD/$s" ~/.claude/skills/"$(basename "$s")"; done

# the research skills additionally need their companion agent + pyyaml
ln -sfn "$PWD/agents/web-search-agent.md"  ~/.claude/agents/web-search-agent.md
ln -sfn "$PWD/agents/web-search-modules"   ~/.claude/agents/web-search-modules
pip install pyyaml
```

That installs the eight active skills. `other_diagraming_tools/` is deliberately
left out — see [The bench](#the-bench).

> **Note:** the research skills are the only ones needing something outside
> `~/.claude/skills/`. Skip the `agents/` lines and they will fail at the
> web-search step.

---

## Repository map

```
agent-skills/
├── skills/                                     ACTIVE — installed, agents use these
│   ├── drawio-skill/                           ★ the diagramming skill  (vendored)
│   ├── frontend-slides/                        HTML presentations       (mine)
│   ├── frontend-reports/                       HTML reports             (mine)
│   ├── research/                               ┐                        (vendored)
│   ├── research-add-items/                     │ deep-research
│   ├── research-add-fields/                    │ pipeline —
│   ├── research-deep/                          │ see below
│   └── research-report/                        ┘
│
├── agents/                                     companion subagent for the research
│   ├── web-search-agent.md                     skills — installs to ~/.claude/agents/
│   └── web-search-modules/                     (academic, github, stackoverflow, …)
│
├── other_diagraming_tools/                     BENCH — reference only, not installed
│   ├── mermaid-diagrams/                       Mermaid source
│   ├── pretty-mermaid/                         Mermaid → SVG/PNG/ASCII
│   ├── excalidraw-diagram-generator/           .excalidraw files
│   ├── plantuml-ascii/                         ASCII diagrams
│   ├── c4-architecture/                        C4 model docs
│   ├── architecture-blueprint-generator/       codebase → arch docs
│   └── create-architectural-decision-record/   ADRs
│
├── azure/                                      assets, not a skill
│   ├── icons/                                  714 official Azure SVG icons, 29 categories
│   ├── icon-index.json                         service name → file path lookup
│   ├── reference-architectures/                Learn diagrams + editable Visio sources
│   ├── Microsoft_Terms_of_Use.pdf              icon licensing — read before use
│   └── Azure_Icons_FAQ.pdf
│
└── README.md
```

---

## Active skills

| Skill | Produces | Use it when | Deps |
|---|---|---|---|
| ★ [**drawio-skill**](skills/drawio-skill/) | `.drawio` XML + PNG/SVG/PDF/JPG export | **Any diagram** — architecture, flowchart, ER, UML, C4, BPMN, SysML, network topology, mind map. Also generates diagrams **from** Terraform, Kubernetes, docker-compose, a SQL schema, or a source tree. | draw.io desktop CLI (required); Graphviz for auto-layout |
| [**frontend-slides**](skills/frontend-slides/) | One self-contained `.html` deck on a fixed 1920×1080 stage | You want an animated presentation that stays 16:9 on every screen, or need a `.pptx` converted to web | Node (PDF export), `python-pptx` (PPTX import) |
| [**frontend-reports**](skills/frontend-reports/) | One self-contained `.html` report, print-ready | You want a scrollable customer-facing document — red team assessment, dataset doc, model card, eval summary | Node (PDF export) |

`drawio-skill` ships 38 Python scripts (infra importers, auto-layout, shape
search, diff, PPTX/Mermaid conversion) and 14 reference docs. The two frontend
skills each ship `scripts/export-pdf.sh` and `scripts/deploy.sh` (Vercel), with
no build step.

---

## Research pipeline

Five skills that work as **one sequence**, not independently. The model is a
research matrix: *items* (the things being compared) × *fields* (the dimensions
being compared on). Good for benchmark surveys, technology selection,
competitive analysis and literature reviews.

```
/research <topic>        build the matrix — items and fields, from model
                         knowledge plus a web-search pass, confirmed with you
      ↓
/research-add-items      widen the matrix (more things to compare)
/research-add-fields     deepen it (more dimensions to compare on)
      ↓
/research-deep           fan out ONE background agent per item to fill its row
      ↓
/research-report         collapse the filled matrix into a markdown report,
                         skipping values it could not establish
```

| Skill | Role |
|---|---|
| [**research**](skills/research/) | Preliminary pass → research outline (items × fields) |
| [**research-add-items**](skills/research-add-items/) | Add research objects to an existing outline |
| [**research-add-fields**](skills/research-add-fields/) | Add field definitions to an existing outline |
| [**research-deep**](skills/research-deep/) | One independent agent per item, run in parallel |
| [**research-report**](skills/research-report/) | Summarize results into a markdown report |

All five are slash-invocable (`/research`, `/research-deep`, …).

**Two extra requirements** — these are the only skills here that need anything
beyond a symlink into `~/.claude/skills/`:

1. `agents/web-search-agent.md` and `agents/web-search-modules/` installed to
   `~/.claude/agents/`
2. `pip install pyyaml`

**Pairs with `frontend-reports`:** `/research-report` emits markdown; hand that
to `frontend-reports` to render it as a polished, print-ready HTML document.

---

## The bench

Everything in [`other_diagraming_tools/`](other_diagraming_tools/) is **benched**:
kept in the repo for reference, comparison and occasional swap-in, but **not
installed and not surfaced to agents**.

**Why.** Seven diagramming skills all claimed the same "diagram / flowchart /
architecture" triggers. With them all installed, *"draw me an architecture
diagram"* had no tiebreaker and resolved close to at random. One primary skill
plus a bench makes the behaviour predictable.

| Benched skill | Produces | Would beat drawio at |
|---|---|---|
| [mermaid-diagrams](other_diagraming_tools/mermaid-diagrams/) | Mermaid source in Markdown | Diagrams that live in git and render natively on GitHub |
| [pretty-mermaid](other_diagraming_tools/pretty-mermaid/) | Themed SVG/PNG/ASCII from existing Mermaid | Re-theming or exporting Mermaid you already have |
| [excalidraw-diagram-generator](other_diagraming_tools/excalidraw-diagram-generator/) | `.excalidraw` JSON | A hand-drawn, whiteboard look |
| [plantuml-ascii](other_diagraming_tools/plantuml-ascii/) | ASCII / Unicode text | Diagrams inside a terminal, code comment, or chat |
| [c4-architecture](other_diagraming_tools/c4-architecture/) | `docs/architecture/c4-*.md` | Formal C4-model docs at several zoom levels |
| [architecture-blueprint-generator](other_diagraming_tools/architecture-blueprint-generator/) | Architecture docs | Reverse-engineering docs from an existing codebase |
| [create-architectural-decision-record](other_diagraming_tools/create-architectural-decision-record/) | An ADR | Recording *why* a decision was made (not a diagram) |

To activate one, symlink it like any other skill:

```bash
ln -sfn "$PWD/other_diagraming_tools/mermaid-diagrams" ~/.claude/skills/mermaid-diagrams
```

Activating one alongside `drawio-skill` is fine. Activating all seven recreates
the ambiguity this structure exists to prevent. See
[`other_diagraming_tools/README.md`](other_diagraming_tools/README.md).

---

## Azure assets

[`azure/`](azure/) holds **assets, not a skill** — nothing there has a `SKILL.md`.

| Path | Contents |
|---|---|
| [`azure/icons/`](azure/icons/) | 714 official Azure service icons (SVG), in their 29 upstream categories |
| [`azure/icon-index.json`](azure/icon-index.json) | Generated lookup: service name → category → path. Resolve icons by name instead of globbing. |
| [`azure/reference-architectures/`](azure/reference-architectures/) | Azure Container Apps architectures from Microsoft Learn — vector SVG, PNG, and an editable `.vsdx` Visio source |

```bash
# find an icon by service name
python3 -c "
import json; i=json.load(open('azure/icon-index.json'))
print([e['path'] for e in i['icons'] if 'key vault' in e['name'].lower()])"
```

Names don't always match intuition — Redis is `Cache-Redis` / `Azure-Managed-Redis`,
the registry is `Container-Registries`. Use the index, not guesswork.

Pairs directly with `drawio-skill`, which can embed these SVGs as shapes.

**The icons are not open source.** Microsoft permits them in architecture
diagrams, training material and documentation; they may not be modified,
recolored, or used to represent your own product. See
[`azure/README.md`](azure/README.md) and the bundled Terms of Use.

---

## Installing

| Scope | How |
|---|---|
| Personal (all projects) | `ln -sfn "$PWD/skills/<name>" ~/.claude/skills/<name>` |
| One project | `ln -sfn "$PWD/skills/<name>" <project>/.claude/skills/<name>` |
| All active skills | see [Quick start](#quick-start) |
| A benched skill | `ln -sfn "$PWD/other_diagraming_tools/<name>" ~/.claude/skills/<name>` |
| Research agents | `ln -sfn "$PWD/agents/web-search-agent.md" ~/.claude/agents/` (+ `web-search-modules`) |

Symlinking (rather than copying) means `git pull` updates every installed skill.
Skills are independent — copy a single directory out and it still works.

---

## Conventions

```
<name>/
  SKILL.md        REQUIRED. YAML frontmatter (name, description) + the workflow.
                  `name` MUST equal the directory name.
  *.md            Reference docs, loaded progressively — not all read up front.
  scripts/        Executable helpers invoked by the workflow.
  LICENSE         Upstream license          (vendored skills only)
  UPSTREAM.md     Source repo, commit, license, and any local changes (vendored only)
```

Adding a skill:

1. `name` in the frontmatter must match the directory name.
2. Write the `description` so it states **what the skill produces** and **when
   not to use it** — that field is all an agent sees when choosing.
3. Every relative path referenced in `SKILL.md` must exist, or be marked optional.
4. Vendoring something? Keep its `LICENSE`, add an `UPSTREAM.md` with the exact
   commit, and record any local modification there.
5. Adding another diagramming skill? Put it on the bench unless it is genuinely
   replacing `drawio-skill` as the primary.

---

## Requirements

Each `SKILL.md` states its own. Across the active skills:

| Dependency | Needed by |
|---|---|
| draw.io desktop CLI | `drawio-skill` — **required** |
| Python 3 | `drawio-skill` (38 scripts) |
| Graphviz (`dot`) | `drawio-skill` auto-layout — optional |
| Node.js | `frontend-slides`, `frontend-reports` (PDF export, deploy) |
| `python-pptx` | `frontend-slides` PPTX conversion only |
| `pyyaml` | the research skills — **required** |
| `~/.claude/agents/web-search-agent.md` | the research skills — **required**, see [Research pipeline](#research-pipeline) |

Playwright + Chromium install themselves on first PDF export. Benched skills add
their own deps (PlantUML, Node for `pretty-mermaid`) only if you activate them.

---

## Licensing

`frontend-slides` and `frontend-reports` are mine. Every diagramming skill —
active or benched — is vendored, **MIT**, and keeps its upstream `LICENSE` plus
an `UPSTREAM.md` pinning the exact source commit.

| Skill(s) | Upstream | License |
|---|---|---|
| `drawio-skill` | [Agents365-ai/drawio-skill](https://github.com/Agents365-ai/drawio-skill) | MIT |
| `mermaid-diagrams`, `c4-architecture` | [softaworks/agent-toolkit](https://github.com/softaworks/agent-toolkit) | MIT |
| `excalidraw-diagram-generator`, `plantuml-ascii`, `architecture-blueprint-generator`, `create-architectural-decision-record` | [github/awesome-copilot](https://github.com/github/awesome-copilot) | MIT |
| `pretty-mermaid` | [imxv/pretty-mermaid-skills](https://github.com/imxv/pretty-mermaid-skills) | MIT |
| `research*` + `agents/` | [Weizhena/Deep-Research-skills](https://github.com/Weizhena/Deep-Research-skills) | MIT |
| `azure/icons/` | Microsoft Azure architecture icons | [Microsoft terms](azure/Microsoft_Terms_of_Use.pdf) — restricted |
| `azure/reference-architectures/` | [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/) | CC BY 4.0 |

The only local change to any vendored skill is its `description` field, rewritten
so `drawio-skill` reads as the primary and the benched skills state their narrow
lane. Each `UPSTREAM.md` records this. To update one: re-copy from upstream at a
newer commit, re-apply the description, and update the SHA.
