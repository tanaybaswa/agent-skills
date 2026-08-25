# agent-skills

My agent skills for Claude Code.

## Skills

| Skill | What it does |
| --- | --- |
| [frontend-slides](skills/frontend-slides/) | Zero-dependency, animation-rich HTML presentations on a fixed 1920×1080 stage. Build from scratch or convert a PPTX. |
| [frontend-reports](skills/frontend-reports/) | Minimal, print-ready single-file HTML reports — red team assessments, dataset docs, model cards, eval summaries. |

## Install

Symlink the skills you want into your personal skills directory:

```bash
mkdir -p ~/.claude/skills
ln -sfn "$PWD/skills/frontend-slides"  ~/.claude/skills/frontend-slides
ln -sfn "$PWD/skills/frontend-reports" ~/.claude/skills/frontend-reports
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
```

## Requirements

The export and deploy scripts need Node.js, and `extract-pptx.py` needs
`python-pptx` (`pip install python-pptx`). Playwright and Chromium install
themselves on first PDF export.
