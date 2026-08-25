# HTML Report Template

Reference architecture for single-file reports.

## Base structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Report Title — Organization</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    /* === PASTE FULL report-base.css HERE === */
  </style>
</head>
<body>
  <article class="report">

    <header class="report-header">
      <h1>Report Title</h1>
      <dl class="report-meta">
        <dt>Date</dt><dd>June 25, 2025</dd>
        <dt>Version</dt><dd>1.0</dd>
        <dt>Prepared by</dt><dd>Organization Name</dd>
        <dt>Classification</dt><dd>Confidential — Client</dd>
      </dl>
    </header>

    <!-- === SECTION: Executive Summary === -->
    <section id="summary">
      <h2>Executive summary</h2>
      <p class="lead">One paragraph overview.</p>
    </section>

    <!-- === SECTION: Metrics === -->
    <section id="metrics">
      <h2>At a glance</h2>
      <div class="metric-grid">
        <div class="metric">
          <div class="metric-value">18</div>
          <div class="metric-label">Total findings</div>
        </div>
        <div class="metric">
          <div class="metric-value">2</div>
          <div class="metric-label">Critical</div>
        </div>
      </div>
    </section>

    <!-- === SECTION: Findings table === -->
    <section id="findings">
      <h2>Findings</h2>
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Severity</th>
              <th>Category</th>
              <th>Title</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>RT-001</td>
              <td><span class="badge critical">Critical</span></td>
              <td>Prompt injection</td>
              <td>System prompt extraction via indirect injection</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- === SECTION: Chart === -->
    <section id="charts">
      <h2>Findings breakdown</h2>
      <figure>
        <div class="figure-chart">
          <canvas id="chart-severity"></canvas>
        </div>
        <figcaption>
          Figure 1. Findings by severity.
          <span class="source">Source: red team assessment, June 2025.</span>
        </figcaption>
      </figure>
    </section>

    <footer class="report-footer">
      <p>Generated June 25, 2025 · Confidential</p>
    </footer>

  </article>

  <!-- Charts: load only if report has charts -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4/dist/chart.umd.min.js"></script>
  <script>
    /* Chart.js defaults + chart configs — see charts.md */
  </script>
</body>
</html>
```

## Naming conventions

- File: `{client-or-project}-{report-type}-{date}.html` (e.g. `acme-redteam-2025-06.html`)
- Chart canvas IDs: `chart-{topic}` (kebab-case)
- Section IDs: match heading topic in kebab-case

## Branding overrides

When user provides logo, add to header only:

```html
<img src="logo.png" alt="Client logo" style="height:32px;margin-bottom:16px;">
```

When user provides accent color, override in `:root`:

```css
:root { --accent: #0066cc; --accent-muted: rgba(0, 102, 204, 0.08); }
```

Do not change layout or typography for branding.

## Multi-page PDF hints

Add `class="page-break"` sparingly before major sections if PDF export splits awkwardly:

```css
@media print {
  .page-break { page-break-before: always; }
}
```
