#!/usr/bin/env python3
"""
make_odp.py — Frontend/Google Slides

Build a minimal OpenDocument Presentation (.odp) from a JSON deck spec, then
print it base64-encoded for upload through the Google Drive connector.

    python3 scripts/make_odp.py deck.json -o deck.odp --base64

Why ODP and not PPTX: Drive converts BOTH to native Google Slides, but an ODP
carrying the same content is ~93% smaller once base64-encoded (a two-slide deck
is ~1.8k characters vs ~25k for .pptx). Since `create_file` takes the encoded
file as a string parameter, that difference is what makes automated upload
practical at all.

Deck spec:

    {
      "slides": [
        {"layout": "title",  "title": "Deck title", "subtitle": "Presenter"},
        {"layout": "bullets","title": "Section",    "bullets": ["one", "two"],
         "notes": "optional speaker notes"}
      ]
    }

No third-party dependencies.
"""

import argparse
import base64
import json
import sys
import zipfile
from xml.sax.saxutils import escape

NS = (
    'xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" '
    'xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" '
    'xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" '
    'xmlns:presentation="urn:oasis:names:tc:opendocument:xmlns:presentation:1.0" '
    'xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"'
)

# 10in x 7.5in in cm, the ODF default presentation page
PAGE_W, PAGE_H = 25.4, 19.05


def frame(cls, x, y, w, h, lines):
    body = "".join("<text:p>%s</text:p>" % escape(str(l)) for l in lines)
    return (
        '<draw:frame presentation:class="%s" svg:x="%gcm" svg:y="%gcm" '
        'svg:width="%gcm" svg:height="%gcm"><draw:text-box>%s</draw:text-box>'
        "</draw:frame>" % (cls, x, y, w, h, body)
    )


def notes(text):
    if not text:
        return ""
    return (
        "<presentation:notes>"
        + frame("notes", 2, 2, PAGE_W - 4, PAGE_H - 4, [text])
        + "</presentation:notes>"
    )


def build_page(index, spec):
    layout = spec.get("layout", "bullets")
    title = spec.get("title", "")
    parts = []

    if layout == "title":
        parts.append(frame("title", 2, PAGE_H * 0.32, PAGE_W - 4, 3, [title]))
        if spec.get("subtitle"):
            parts.append(
                frame("subtitle", 2, PAGE_H * 0.32 + 3.4, PAGE_W - 4, 2, [spec["subtitle"]])
            )
    elif layout == "section":
        parts.append(frame("title", 2, PAGE_H * 0.42, PAGE_W - 4, 3, [title]))
    else:  # bullets
        parts.append(frame("title", 2, 1.5, PAGE_W - 4, 2, [title]))
        bullets = spec.get("bullets") or []
        if bullets:
            parts.append(frame("outline", 2, 4.2, PAGE_W - 4, PAGE_H - 6, bullets))

    return (
        '<draw:page draw:name="Slide%d">' % index
        + "".join(parts)
        + notes(spec.get("notes"))
        + "</draw:page>"
    )


def build_odp(deck, path):
    slides = deck.get("slides") or []
    if not slides:
        sys.exit("error: deck spec has no slides")

    pages = "".join(build_page(i, s) for i, s in enumerate(slides, start=1))
    content = (
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<office:document-content %s office:version="1.2">'
        "<office:body><office:presentation>%s</office:presentation></office:body>"
        "</office:document-content>" % (NS, pages)
    )
    styles = (
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<office:document-styles %s office:version="1.2">'
        "<office:styles/></office:document-styles>" % NS
    )
    manifest = (
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" '
        'manifest:version="1.2">'
        '<manifest:file-entry manifest:full-path="/" '
        'manifest:media-type="application/vnd.oasis.opendocument.presentation"/>'
        '<manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>'
        '<manifest:file-entry manifest:full-path="styles.xml" manifest:media-type="text/xml"/>'
        "</manifest:manifest>"
    )

    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        # Per the ODF spec `mimetype` must be the FIRST entry and STORED
        # (uncompressed). Get this wrong and the file is not recognised.
        zi = zipfile.ZipInfo("mimetype")
        zi.compress_type = zipfile.ZIP_STORED
        z.writestr(zi, "application/vnd.oasis.opendocument.presentation")
        z.writestr("META-INF/manifest.xml", manifest)
        z.writestr("content.xml", content)
        z.writestr("styles.xml", styles)

    return len(slides)


def main():
    ap = argparse.ArgumentParser(description="Build a minimal .odp from a JSON deck spec")
    ap.add_argument("spec", help="path to the JSON deck spec, or - for stdin")
    ap.add_argument("-o", "--out", default="deck.odp", help="output .odp path")
    ap.add_argument("--base64", action="store_true",
                    help="print the base64 of the result, for create_file(base64Content=...)")
    args = ap.parse_args()

    raw = sys.stdin.read() if args.spec == "-" else open(args.spec, encoding="utf-8").read()
    deck = json.loads(raw)

    n = build_odp(deck, args.out)

    with open(args.out, "rb") as fh:
        data = fh.read()
    b64 = base64.b64encode(data).decode()

    if args.base64:
        print(b64)
    else:
        print("wrote %s — %d slides, %d bytes, %d base64 chars"
              % (args.out, n, len(data), len(b64)), file=sys.stderr)
        if len(b64) > 20000:
            print("warning: %d base64 chars is large for a single tool parameter; "
                  "consider splitting the deck or handing the file to the user"
                  % len(b64), file=sys.stderr)


if __name__ == "__main__":
    main()
