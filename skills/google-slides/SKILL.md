---
name: google-slides
description: 'Create, read and update decks in Google Slides — a real presentation in the user''s Google Drive, shareable by link, editable by colleagues, with comments and live collaboration. Use when the user names Google Slides, Google Drive, or wants a deck their team can co-edit or comment on. Two routes are supported: the official Google Slides MCP server for direct read/modify/write on a live deck, or generating a .pptx and uploading it to Drive with automatic conversion when only the Drive connector is available. This is one of three presentation skills in this repo, split by output artifact: use frontend-slides for a self-contained animated HTML deck, and the built-in pptx skill for a .pptx file on disk.'
---

# Google Slides

Produce a real Google Slides presentation in the user's Drive — not an HTML page,
not a local file. The deliverable is a Drive file ID and a shareable link.

## When this skill is the right one

This repo has **three peer presentation skills**, chosen by the artifact you need:

| Deliverable | Skill |
| --- | --- |
| A Google Slides deck others can co-edit and comment on | **this skill** |
| A self-contained animated HTML deck on a fixed 16:9 stage | `frontend-slides` |
| A `.pptx` file on disk | the built-in `pptx` skill |

They are peers, not ranked. Pick by what the user will do with the result:
collaborate → Slides, publish a link you control → HTML, send an attachment or
hand to a corporate template → pptx.

If the user is ambiguous ("make me a deck"), ask which they want rather than
guessing — the three are not interchangeable once delivered.

---

## Phase 0: Detect which route is available

Check, in this order, and tell the user which route you are taking:

1. **Google Slides MCP server** — look for tools named `read_presentation` /
   `update_presentation`. If present, use **Route A**. Full read/modify/write.
2. **Google Drive connector only** — look for `create_file` on a Google Drive
   MCP server. If present, use **Route B**. One-shot creation.
3. **Neither** — stop and tell the user what to set up. See
   [references/mcp-setup.md](references/mcp-setup.md). Do not silently fall back
   to producing an HTML deck or a local file; that is a different deliverable
   than the one they asked for.

---

## Route A: Google Slides MCP server (preferred)

The official server exposes two tools:

- `read_presentation` — presentation structure and styles
- `update_presentation` — mutates layouts, slides and elements

This is the only route that can **edit an existing deck**. Use it when the user
wants to revise a specific slide, apply a theme to a deck that already exists, or
iterate over several rounds.

Workflow:

1. **Read first, always.** Call `read_presentation` before any mutation, even on
   a deck you just created. You need current object IDs — they are not stable
   across your assumptions, only across reads.
2. **Plan the full slide sequence** before writing (see
   [references/deck-design.md](references/deck-design.md)).
3. **Batch your updates.** `update_presentation` applies a series of changes;
   one well-formed batch beats many round trips, and partial application on
   failure is easier to reason about in a single batch.
4. **Re-read to verify.** Confirm slide count, that no text box overflows its
   placeholder, and that speaker notes landed.
5. **Report the deck URL** to the user.

**Preview caveat:** this server is in Google Workspace Developer Preview. It
requires OAuth 2.0 and program enrollment, and the tool surface may change. If a
call fails with an auth or availability error, say so plainly and offer Route B —
do not retry in a loop.

---

## Route B: Build an ODP and upload it (fully automated)

When only the Drive connector is available. Drive converts uploaded office
documents to native Google formats automatically, so an uploaded presentation
becomes a real, editable Google Slides deck.

**Author the deck as ODP, not PPTX.** Both convert to Slides, but `base64Content`
is a *string parameter* — the entire encoded file has to be reproduced exactly in
the tool call. An ODP carrying the same content is roughly **93% smaller** once
encoded (a two-slide deck is ~1,800 base64 characters versus ~25,000 for `.pptx`).
That difference is the whole reason this route is usable: `.pptx` is large enough
that a single mis-transcribed character makes the upload fail, while ODP fits
comfortably in one call.

1. **Write a deck spec** — plain JSON:

   ```json
   {
     "slides": [
       {"layout": "title",   "title": "Q3 Architecture Review", "subtitle": "Platform team"},
       {"layout": "section", "title": "Where we are"},
       {"layout": "bullets", "title": "Current state",
        "bullets": ["Five services in one environment", "Two datastores"],
        "notes": "Optional speaker notes"}
     ]
   }
   ```

   Layouts: `title`, `section`, `bullets`.

2. **Build the .odp and get its base64:**

   ```bash
   python3 scripts/make_odp.py deck.json -o deck.odp --base64
   ```

   Run without `--base64` first to see the size. The script warns when the encoded
   deck exceeds ~20,000 characters, which is the point at which a single upload
   call becomes unreliable.

3. **Upload it, leaving conversion ON:**

   ```
   create_file(
     title            = "Q3 Architecture Review",
     base64Content    = <output of --base64>,
     contentMimeType  = "application/vnd.oasis.opendocument.presentation",
     parentId         = <optional destination folder id>
   )
   ```

   Do **not** set `disableConversionToGoogleType: true` — that leaves an inert
   ODP file in Drive instead of converting it to Slides.

   Copy the base64 exactly. It is rejected outright if even one character is
   wrong; there is no partial success.

4. **Confirm and verify.** The `create_file` response should already show
   `"mimeType": "application/vnd.google-apps.presentation"`. Then call
   `read_file_content` to confirm the slides and their text actually landed —
   do not report success from the upload response alone.

5. **Report the deck URL** from `viewUrl`.

### When to use .pptx instead

Use the built-in `pptx` skill, and **hand the file to the user** rather than
uploading it, when the deck needs more than this route offers — real themes,
images, tables, precise layout, or corporate template inheritance. Give them the
path and let them drop it into Drive; the same automatic conversion applies, with
no size limit and no setup. One manual step, and it handles any deck.

Rule of thumb: **ODP for automated delivery, PPTX for rich decks handed off.**

### Limitation: this route cannot edit

**The Drive connector cannot change a deck's content after upload.** Its
`update_file` tool supports only `title` and `parentId` — metadata, not slides.

Revisions mean rebuilding the ODP and uploading again, producing a **new file at
a new URL**. Tell the user up front if they are likely to want edits. To iterate
on one stable link, they need Route A.

### Verified behavior (2026-08-25)

Tested directly against the Google Drive connector:

| Behavior | Result |
| --- | --- |
| Upload converts to a Google first-party type by default | **Confirmed** — `text/plain` came back as `application/vnd.google-apps.document` |
| `create_file` creates a native, empty Slides file | **Confirmed** — returned a working `docs.google.com/presentation/...` URL |
| **ODP upload → native Google Slides, with content** | **Confirmed** — a 1,341-byte ODP (1,788 base64 chars) converted to `application/vnd.google-apps.presentation`; `read_file_content` returned both slides, the subtitle, and all four bullets in order |
| `scripts/make_odp.py` output converts identically | **Confirmed** — script-generated deck converted and read back correctly |
| `.pptx` upload via `base64Content` | **Failed** — ~25,000 base64 characters could not be reproduced exactly in one tool call. Use ODP, or hand the `.pptx` to the user. |
| Speaker notes surviving conversion | **Unverified** — `read_file_content` does not surface notes, so this was not confirmed either way |

## Creating an empty deck

`create_file` can create `application/vnd.google-apps.presentation` with no
content at all — useful only as a container to then populate via Route A. On
Route B an empty deck is a dead end, since you cannot fill it afterwards.

---

## Sharing

Once the deck exists, share it when asked:

```
share_file(fileId = <id>, emailAddress = <recipient>, role = "writer" | "commenter" | "reader")
```

Pick the least access that serves the purpose — `commenter` for review,
`reader` for distribution, `writer` only for genuine co-authors. Sharing is
outward-facing: confirm the recipient list with the user before sending, and
never widen an existing permission without being asked.

---

## Reading an existing deck

`read_file_content(fileId, includeComments = true)` returns a Slides deck as text
and can inline comment threads. Use it to review, summarize, or audit a deck
before revising it. To locate a deck by name, use `search_files` with a mimeType
clause and keep the file-type word out of the title match:

```
mimeType = 'application/vnd.google-apps.presentation' and title contains 'architecture'
```

---

## Verification before reporting done

- [ ] The file exists and its mime type is `application/vnd.google-apps.presentation`
- [ ] Slide count matches the plan
- [ ] No text overflows its placeholder (re-read and check, don't assume)
- [ ] Speaker notes landed, if the user asked for them
- [ ] The reported URL actually opens the deck
- [ ] On Route B, the user has been told edits produce a new URL

## Supporting files

| File | Purpose | When |
| --- | --- | --- |
| [references/mcp-setup.md](references/mcp-setup.md) | Configuring the Google Slides MCP server, and what to tell the user when nothing is connected | Phase 0, route unavailable |
| [references/deck-design.md](references/deck-design.md) | Slide structure, density, and what translates poorly into Slides | Before generating |
| [scripts/make_odp.py](scripts/make_odp.py) | Builds a minimal `.odp` from a JSON deck spec and prints its base64 | Route B, step 2 |
