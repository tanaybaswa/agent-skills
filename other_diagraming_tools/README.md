# other_diagraming_tools — the bench

These are **benched**. They are kept in this repo for reference, comparison and
occasional swap-in, but they are **not installed by default and agents are not
directed to them**.

[`drawio-skill`](../skills/drawio-skill/) is the one diagramming skill in
`skills/`, and it is the default for every diagram request.

## Why bench them

Seven skills all claimed the same "diagram / flowchart / architecture" triggers.
With all of them installed, a request like *"draw me an architecture diagram"*
had no tiebreaker and resolved more or less at random. Picking one primary and
benching the rest makes the behaviour predictable.

## What's on the bench

| Skill | Produces | Would beat drawio at |
|---|---|---|
| [mermaid-diagrams](mermaid-diagrams/) | Mermaid source in Markdown | Diagrams that live in git and render natively on GitHub |
| [pretty-mermaid](pretty-mermaid/) | Themed SVG/PNG/ASCII from existing Mermaid | Re-theming or exporting Mermaid you already have |
| [excalidraw-diagram-generator](excalidraw-diagram-generator/) | `.excalidraw` JSON | A hand-drawn, whiteboard look |
| [plantuml-ascii](plantuml-ascii/) | ASCII / Unicode text | Diagrams inside a terminal, code comment, or chat |
| [c4-architecture](c4-architecture/) | `docs/architecture/c4-*.md` | Formal C4-model documentation at several zoom levels |
| [architecture-blueprint-generator](architecture-blueprint-generator/) | Architecture docs | Reverse-engineering docs from an existing codebase |
| [create-architectural-decision-record](create-architectural-decision-record/) | An ADR | Recording *why* a decision was made (not a diagram at all) |

`drawio-skill` covers Mermaid authoring, C4, UML, BPMN and ASCII-adjacent output
too — the bench entries win only in the narrow cases above.

## Activating one

Symlink it like any other skill:

```bash
ln -sfn "$PWD/other_diagraming_tools/mermaid-diagrams" ~/.claude/skills/mermaid-diagrams
```

Their `description` fields still cross-reference each other by name, which is
correct if you activate several — but the more you activate, the more the
original ambiguity returns. Activating one alongside `drawio-skill` is fine;
activating all seven recreates the problem.

## Licensing

All MIT. Each directory keeps its upstream `LICENSE` and an `UPSTREAM.md` with
the exact source commit. The only local modification is the `description` field.
See the [licensing table](../README.md#licensing) in the root README.
