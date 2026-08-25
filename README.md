# agent-skills

My agent skills for Claude Code — HTML deliverables (slides, reports) and a
complete toolkit for diagrams and software architecture, plus the official Azure
icon set and reference architectures.

**10 skills** · self-contained directories · drop-in for `~/.claude/skills/`

---

## Contents

- [Quick start](#quick-start)
- [Repository map](#repository-map)
- [Skill index](#skill-index)
  - [Authored here](#authored-here)
  - [Diagrams & software architecture](#diagrams--software-architecture)
- [Which diagram skill should I use?](#which-diagram-skill-should-i-use)
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
mkdir -p ~/.claude/skills
for s in skills/*/; do ln -sfn "$PWD/$s" ~/.claude/skills/"$(basename "$s")"; done
```

Symlinking (rather than copying) means `git pull` updates every installed skill.

---

## Repository map

```
agent-skills/
├── skills/                                     10 skills, one directory each
│   ├── frontend-slides/                        HTML presentations       (mine)
│   ├── frontend-reports/                       HTML reports             (mine)
│   ├── drawio-skill/                           .drawio files            (vendored)
│   ├── mermaid-diagrams/                       Mermaid source           (vendored)
│   ├── pretty-mermaid/                         Mermaid → SVG/PNG/ASCII  (vendored)
│   ├── excalidraw-diagram-generator/           .excalidraw files        (vendored)
│   ├── plantuml-ascii/                         ASCII diagrams           (vendored)
│   ├── c4-architecture/                        C4 model docs            (vendored)
│   ├── architecture-blueprint-generator/       codebase → arch docs     (vendored)
│   └── create-architectural-decision-record/   ADRs                     (vendored)
│
├── azure/                                      diagram assets, not a skill
│   ├── icons/                                  714 official Azure SVG icons, 29 categories
│   ├── icon-index.json                         service name → file path lookup
│   ├── reference-architectures/                Learn diagrams + editable Visio sources
│   ├── Microsoft_Terms_of_Use.pdf              icon licensing — read before use
│   └── Azure_Icons_FAQ.pdf
│
└── README.md
```

---

## Skill index

### Authored here

| Skill | Produces | Use it when | Deps |
|---|---|---|---|
| [**frontend-slides**](skills/frontend-slides/) | One self-contained `.html` deck on a fixed 1920×1080 stage | You want an animated presentation that stays 16:9 on every screen, or need a `.pptx` converted to web | Node (PDF export), `python-pptx` (PPTX import) |
| [**frontend-reports**](skills/frontend-reports/) | One self-contained `.html` report, print-ready | You want a scrollable customer-facing document — red team assessment, dataset doc, model card, eval summary | Node (PDF export) |

Both ship `scripts/export-pdf.sh` and `scripts/deploy.sh` (Vercel). Neither has a
build step; charts come from a CDN, fonts from Fontshare/Google Fonts.

### Diagrams & software architecture

All eight are vendored from upstream projects — see [Licensing](#licensing).

| Skill | Produces | Use it when | Deps |
|---|---|---|---|
| [**drawio-skill**](skills/drawio-skill/) | `.drawio` XML + PNG/SVG/PDF export | You need an **editable draw.io file**, a rich shape vocabulary (cloud icons, BPMN, SysML, swimlanes), or a diagram generated **from** Terraform / Kubernetes / SQL / a codebase | draw.io desktop CLI; Graphviz for auto-layout |
| [**mermaid-diagrams**](skills/mermaid-diagrams/) | Mermaid source inside Markdown | The diagram should **live in git** and render natively on GitHub | none |
| [**pretty-mermaid**](skills/pretty-mermaid/) | Themed SVG / PNG / ASCII **from existing** Mermaid | You already have Mermaid and want it themed, exported, or made terminal-friendly (15 themes) | Node |
| [**excalidraw-diagram-generator**](skills/excalidraw-diagram-generator/) | `.excalidraw` JSON | You want a **hand-drawn / whiteboard** look you'll keep rearranging | Python (icon importer) |
| [**plantuml-ascii**](skills/plantuml-ascii/) | ASCII / Unicode text | The diagram must render in a **terminal, code comment, or chat** — no image file | PlantUML |
| [**c4-architecture**](skills/c4-architecture/) | `docs/architecture/c4-*.md` | You're documenting a system with the **C4 model** — context, container, component, deployment | none |
| [**architecture-blueprint-generator**](skills/architecture-blueprint-generator/) | Architecture documentation | You point it at an **existing repo** and want its architecture reverse-engineered | none |
| [**create-architectural-decision-record**](skills/create-architectural-decision-record/) | An ADR document | You're recording **why** a decision was made | none |

---

## Which diagram skill should I use?

Seven of these overlap on the word "diagram". The deciding question is almost
always **what artifact do you want to end up with?**

| I want… | Use |
|---|---|
| A file I can keep editing in draw.io | `drawio-skill` |
| A diagram that renders on GitHub in my README/PR | `mermaid-diagrams` |
| My existing Mermaid turned into a nice image | `pretty-mermaid` |
| Something sketchy I'll rearrange on a whiteboard | `excalidraw-diagram-generator` |
| Something that renders in a terminal | `plantuml-ascii` |
| A diagram built from my Terraform/K8s/SQL/code | `drawio-skill` |
| Layered architecture docs at several zoom levels | `c4-architecture` |
| Architecture docs for a repo that already exists | `architecture-blueprint-generator` |
| A record of why we chose X over Y | `create-architectural-decision-record` |

Common pairing: author with `mermaid-diagrams`, then render with `pretty-mermaid`.

> Each skill's `description` field states its lane and names the sibling to use
> instead, so an agent picks correctly without reading this table. If you add a
> new diagram skill, keep that discipline or triggering degrades for all of them.

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
| Everything | see [Quick start](#quick-start) |

Skills are independent — copy a single directory out and it still works.

---

## Conventions

```
skills/<name>/
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

---

## Requirements

Each `SKILL.md` states its own. Across the repo:

| Dependency | Needed by |
|---|---|
| Node.js | `frontend-slides`, `frontend-reports` (PDF export, deploy), `pretty-mermaid` |
| Python 3 | `drawio-skill` (38 scripts), `excalidraw-diagram-generator` |
| draw.io desktop CLI | `drawio-skill` — required |
| Graphviz (`dot`) | `drawio-skill` auto-layout — optional |
| PlantUML | `plantuml-ascii` |
| `python-pptx` | `frontend-slides` PPTX conversion only |

Playwright + Chromium install themselves on first PDF export.

---

## Licensing

`frontend-slides` and `frontend-reports` are mine. Everything under
[Diagrams & software architecture](#diagrams--software-architecture) is vendored,
**MIT**, and keeps its upstream `LICENSE` plus an `UPSTREAM.md` pinning the exact
commit it came from.

| Skill(s) | Upstream | License |
|---|---|---|
| `drawio-skill` | [Agents365-ai/drawio-skill](https://github.com/Agents365-ai/drawio-skill) | MIT |
| `mermaid-diagrams`, `c4-architecture` | [softaworks/agent-toolkit](https://github.com/softaworks/agent-toolkit) | MIT |
| `excalidraw-diagram-generator`, `plantuml-ascii`, `architecture-blueprint-generator`, `create-architectural-decision-record` | [github/awesome-copilot](https://github.com/github/awesome-copilot) | MIT |
| `pretty-mermaid` | [imxv/pretty-mermaid-skills](https://github.com/imxv/pretty-mermaid-skills) | MIT |
| `azure/icons/` | Microsoft Azure architecture icons | [Microsoft terms](azure/Microsoft_Terms_of_Use.pdf) — restricted |
| `azure/reference-architectures/` | [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/) | CC BY 4.0 |

The only local change to any vendored skill is the `description` field, rewritten
to stop seven skills from claiming the same triggers. Each `UPSTREAM.md` records
this. To update a vendored skill: re-copy from upstream at a newer commit, re-apply
the description, and update the SHA.
