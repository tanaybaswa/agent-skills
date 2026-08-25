# Designing for Google Slides

Google Slides is a collaborative document, not a canvas you fully control. Design
for that.

## Structure first

Plan the whole sequence before creating anything — on Route B you cannot revise
in place, and on Route A a planned batch beats incremental patching.

A working default:

1. Title slide — title, subtitle, presenter, date
2. Agenda / the question this deck answers
3. Body sections, one idea per slide
4. Summary or decision slide
5. Appendix (detail that would break the narrative)

## Density

Ask, or infer from context:

| Mode | For | Behavior |
| --- | --- | --- |
| **Speaker-led** | Live presentation | One idea per slide, large type, 1–3 bullets, more slides |
| **Reading-first** | Async circulation, review decks | Self-contained slides, 4–6 bullets, tables, notes carry detail |

Circulated decks — the common case for Slides, since the deliverable is a link —
lean reading-first. Someone will open it without you in the room.

## Use the layouts

Bind content to the theme's real placeholders (`TITLE`, `SUBTITLE`, `BODY`)
rather than dropping free-floating text boxes. Placeholder text inherits theme
fonts and colors, survives a theme change, and stays editable in the normal UI.
Free text boxes look right until someone switches the theme, then don't.

Prefer the built-in themes over hand-set colors on every element. A colleague
changing the theme should not have to repair the deck.

## Speaker notes

Put the detail there rather than cramming the slide. Notes are the natural place
for the argument behind a claim, sources, and numbers you don't want on screen.

## What translates poorly

- **Animation.** Slides' animation model is limited and often ignored in
  presenter view. Don't build meaning that depends on build order — if the deck
  needs motion, `frontend-slides` is the better artifact.
- **Precise typography.** Tracking, custom fonts, and exact kerning don't survive.
  Anything typographically load-bearing belongs in HTML.
- **Full-bleed edge-to-edge design.** Achievable but fragile once someone edits.
- **Dense tables.** Past roughly 6 columns, link a Sheet instead.

## Images and diagrams

Slides renders SVG poorly — convert diagrams to PNG before inserting. This
matters when pulling from `drawio-skill`, whose native export includes SVG:
export PNG for Slides. The Azure icons in `azure/icons/` are SVG and need the
same treatment.

## Before you call it done

- Re-read the deck; don't assume a write landed
- Check no text overflows its placeholder
- Confirm slide order matches the plan
- Confirm the link opens for someone who isn't you, if it's being shared
