# Azure

Assets for drawing Azure architecture diagrams — the official icon set plus
reference architectures pulled from Microsoft Learn.

## Contents

| Path | What |
| --- | --- |
| [`icons/`](icons/) | 714 official Azure service icons (SVG) in 29 category folders, from `Azure_Public_Service_Icons_V24` |
| [`icon-index.json`](icon-index.json) | Generated lookup: service name → category → file path. Use this to resolve an icon by name instead of globbing the tree. |
| [`reference-architectures/`](reference-architectures/) | Microsoft Learn reference architectures — diagrams and editable Visio sources |
| `Microsoft_Terms_of_Use.pdf` | Microsoft's terms for the icon set — read before using |
| `Azure_Icons_FAQ.pdf` | Microsoft's FAQ for the icon set |

## Using the icons

Look up a service in `icon-index.json`, then reference the SVG path:

```bash
python3 -c "
import json; idx=json.load(open('azure/icon-index.json'))
print([e['path'] for e in idx['icons'] if 'key vault' in e['name'].lower()])"
# -> ['azure/icons/security/10245-icon-service-Key-Vaults.svg']
```

Icon filenames follow `{id}-icon-service-{Service-Name}.svg`. Some icons appear
in more than one category (for example Application Insights is under both
`devops` and `management + governance`) — either path is the same file.

Pairs well with `drawio-skill` (embed SVGs as shapes) and
`excalidraw-diagram-generator` (has an icon-embedding script).

## Terms — read this

The icons are **not** open source. Microsoft's terms:

> Microsoft permits the use of these icons in architectural diagrams, training
> materials, or documentation. You may copy, distribute, and display the icons
> only for the permitted use unless granted explicit permission by Microsoft.
> Microsoft reserves all other rights.

In practice:

- **Do** use them in architecture diagrams, and put the product name near the icon.
- **Do** use them as they appear in Azure.
- **Don't** distort, recolor, or change the icon shapes.
- **Don't** use Microsoft product icons to represent your own product or service.

Full terms in `Microsoft_Terms_of_Use.pdf`.
