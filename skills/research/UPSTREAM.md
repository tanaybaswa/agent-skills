# Upstream

This skill is vendored from a third-party repository. It is **not** my own work.

| | |
| --- | --- |
| Source | https://github.com/Weizhena/Deep-Research-skills |
| Path in source | `skills/research-en/research` |
| Commit | `6ce38f60e3f8b22502c29873f96503a4e0c5addb` |
| Retrieved | 2026-08-25 |
| License | MIT (c) 2026 Lan Zheng (see `LICENSE` in this directory) |

Only the English / Claude Code variant is vendored. Upstream also ships Chinese
(`research-zh`) and Codex (`research-codex-*`) variants of these same five
skills, plus an OpenCode agent.

**Extra install step:** these skills require the companion web-search agent in
this repo's [`agents/`](../../agents/) directory to be installed to
`~/.claude/agents/`, and `pip install pyyaml`. They will not work from
`~/.claude/skills/` alone.

Local changes: none.
