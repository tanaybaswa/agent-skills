# agent-skills

My agent skills for Claude Code.

## Skills

### Mine

| Skill | What it does |
| --- | --- |
| [frontend-slides](skills/frontend-slides/) | Zero-dependency, animation-rich HTML presentations on a fixed 1920×1080 stage. Build from scratch or convert a PPTX. |
| [frontend-reports](skills/frontend-reports/) | Minimal, print-ready single-file HTML reports — red team assessments, dataset docs, model cards, eval summaries. |

### Diagrams & software architecture

Vendored from upstream projects — see [Third-party skills](#third-party-skills).

| Skill | What it does |
| --- | --- |
| [drawio-skill](skills/drawio-skill/) | Natural language, a codebase, Terraform/K8s, or a SQL schema → `.drawio` XML, exported to PNG/SVG/PDF via the draw.io CLI. 11 diagram presets, Mermaid→drawio, shape search. |
| [mermaid-diagrams](skills/mermaid-diagrams/) | Mermaid authoring across class, sequence, state, ER, flowchart, and deployment diagrams. Diagrams-as-code that live in git and render in Markdown. |
| [c4-architecture](skills/c4-architecture/) | C4 model architecture docs — context, container, and component views as Mermaid. |
| [excalidraw-diagram-generator](skills/excalidraw-diagram-generator/) | Excalidraw diagrams from natural language, with templates for flowcharts, ERDs, swimlanes, mind maps, sequence and class diagrams. Hand-drawn/whiteboard look. |
| [pretty-mermaid](skills/pretty-mermaid/) | Renders Mermaid to themed SVG/PNG or ASCII art for READMEs, PRs, terminals, and CI. Complements `mermaid-diagrams` — that one authors, this one makes it look good. |
| [plantuml-ascii](skills/plantuml-ascii/) | PlantUML in text mode → ASCII/terminal-friendly diagrams. |
| [architecture-blueprint-generator](skills/architecture-blueprint-generator/) | Analyzes a codebase, detects the stack and architectural patterns, and generates architecture documentation with diagrams. |
| [create-architectural-decision-record](skills/create-architectural-decision-record/) | Writes ADRs in a structured, AI-readable format. |

**Picking one:** `mermaid-diagrams` for anything that should live in git and render on GitHub. `drawio-skill` when you need rich shape vocabulary, swimlanes, or a polished exportable image. `excalidraw-diagram-generator` for a sketchy, whiteboard feel. `c4-architecture` when the subject is system architecture specifically. `plantuml-ascii` when it has to render in a terminal.

## Install

Symlink the skills you want into your personal skills directory:

```bash
mkdir -p ~/.claude/skills
ln -sfn "$PWD/skills/frontend-slides" ~/.claude/skills/frontend-slides
# ...or all of them:
for s in skills/*/; do ln -sfn "$PWD/$s" ~/.claude/skills/"$(basename "$s")"; done
```

For a single project instead, symlink into that project's `.claude/skills/`.

## Layout

Each skill is a self-contained directory — `SKILL.md` plus whatever reference
docs, CSS, and scripts it needs. Nothing is shared between skills, so a
directory can be copied out on its own and still work.

```
skills/<name>/
  SKILL.md        name + description frontmatter, then the workflow
  *.md / *.css    reference files, loaded progressively as the workflow needs them
  scripts/        executable helpers
  LICENSE         upstream license (vendored skills only)
  UPSTREAM.md     source repo, commit, license (vendored skills only)
```

## Third-party skills

Every skill under "Diagrams & software architecture" is copied from an upstream
project and is not my work. Each directory keeps its upstream `LICENSE` and an
`UPSTREAM.md` recording the source repo, the exact commit it was taken from, and
the license. All are MIT.

| Skill | Upstream |
| --- | --- |
| drawio-skill | [Agents365-ai/drawio-skill](https://github.com/Agents365-ai/drawio-skill) |
| mermaid-diagrams, c4-architecture | [softaworks/agent-toolkit](https://github.com/softaworks/agent-toolkit) |
| excalidraw-diagram-generator, plantuml-ascii, architecture-blueprint-generator, create-architectural-decision-record | [github/awesome-copilot](https://github.com/github/awesome-copilot) |
| pretty-mermaid | [imxv/pretty-mermaid-skills](https://github.com/imxv/pretty-mermaid-skills) |

To update one: re-copy from upstream at a newer commit and update the SHA in its
`UPSTREAM.md`. None of them carry local modifications.

## Requirements

Varies by skill; each `SKILL.md` states its own. Broadly: Node.js for the HTML
export/deploy scripts, Python for most diagram tooling, the draw.io desktop CLI
for `drawio-skill`, and `python-pptx` for PPTX conversion.
