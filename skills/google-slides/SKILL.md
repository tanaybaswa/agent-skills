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

## Route B: Generate .pptx, upload with conversion

When only the Drive connector is available. Google Drive converts uploaded
Office files to native Google formats **by default**, so a `.pptx` upload becomes
a real, fully editable Google Slides deck.

1. **Build the deck as .pptx** using the built-in `pptx` skill. Everything that
   skill knows about layouts, masters and speaker notes applies — this route does
   not replace it, it consumes its output.

2. **Upload with conversion left ON:**

   ```
   create_file(
     title            = "Q3 Architecture Review",        # becomes the deck name
     base64Content    = <the .pptx file, base64 encoded>,
     contentMimeType  = "application/vnd.openxmlformats-officedocument.presentationml.presentation",
     parentId         = <optional destination folder id>
   )
   ```

   Do **not** set `disableConversionToGoogleType: true` — that flag keeps the file
   as an inert `.pptx` sitting in Drive rather than converting it to Slides, which
   defeats the purpose of this route.

   Use `base64Content` (a `.pptx` is a binary zip), never `textContent`.

3. **Confirm it converted.** Call `get_file_metadata` and check the mime type is
   `application/vnd.google-apps.presentation`. If it is still the pptx mime type,
   the conversion did not happen — say so rather than reporting success.

4. **Report the deck URL.**

### Read this before choosing Route B

**The upload leg is unreliable for real decks.** `base64Content` is a string
parameter, so the entire encoded file has to be reproduced exactly in the tool
call. A minimal two-slide deck is already ~25,000 base64 characters, and
reproducing that verbatim fails in practice — a single wrong character is
rejected outright as invalid base64.

Treat Route B's automated upload as viable only for very small files. For a real
deck, prefer one of these:

- **Route A**, if the Slides MCP server is available. This is the only fully
  automated path.
- **Hand off the file.** Generate the `.pptx` locally with the `pptx` skill, give
  the user the path, and have them drag it into Drive. Drive converts it to
  Slides on upload — no flag needed, no setup. One manual step, completely
  reliable, and it works for a deck of any size.

Do not burn several attempts retrying a large base64 upload. Recognise the size
and offer the handoff instead.

### Other limitations of Route B

**The Drive connector cannot change a deck's content after upload.** Its
`update_file` tool supports only `title` and `parentId` — metadata, not slides.

So on this route, revisions mean regenerating the `.pptx` and uploading again,
which produces a **new file with a new URL**. Tell the user this up front if they
are likely to want edits. If they need to iterate on one stable link, they need
Route A.

### Verified behavior (2026-08-25)

Tested directly against the Google Drive connector:

| Behavior | Result |
| --- | --- |
| Upload converts to a Google first-party type by default | **Confirmed** — `text/plain` upload returned `application/vnd.google-apps.document` |
| `create_file` can create a native Slides file with no content | **Confirmed** — returned `application/vnd.google-apps.presentation` with a working `docs.google.com/presentation/...` URL |
| Uploading a real `.pptx` via `base64Content` | **Failed** — a ~25,000-character base64 string could not be reproduced exactly in the tool call. This is the limitation described above, not a connector fault. |

---

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
