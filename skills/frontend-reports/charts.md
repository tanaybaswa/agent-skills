# Chart Patterns (Chart.js)

Load Chart.js once via CDN:

```html
<script src="https://cdn.jsdelivr.net/npm/chart.js@4/dist/chart.umd.min.js"></script>
```

## Colorblind-safe palette

Use in order for multi-series charts:

```javascript
const PALETTE = [
  '#2563eb', // blue
  '#059669', // green
  '#d97706', // amber
  '#dc2626', // red
  '#7c3aed', // violet
  '#0891b2', // cyan
  '#64748b', // slate
];
```

Severity-specific (not for general series):

```javascript
const SEVERITY_COLORS = {
  critical: '#991b1b',
  high:     '#9a3412',
  medium:   '#854d0e',
  low:      '#166534',
};
```

## Global defaults

Apply before creating charts:

```javascript
Chart.defaults.font.family = "'IBM Plex Sans', sans-serif";
Chart.defaults.font.size = 12;
Chart.defaults.color = '#5c5c5c';
Chart.defaults.plugins.legend.labels.boxWidth = 12;
Chart.defaults.plugins.legend.labels.padding = 16;
Chart.defaults.scale.grid.color = '#f0f0f0';
Chart.defaults.scale.grid.drawBorder = false;
Chart.defaults.scale.ticks.padding = 8;
```

## HTML figure wrapper

```html
<figure>
  <div class="figure-chart">
    <canvas id="chart-findings-severity"></canvas>
  </div>
  <figcaption>
    Figure 1. Findings by severity level.
    <span class="source">Source: assessment run 2025-06-01.</span>
  </figcaption>
</figure>
```

## Bar chart (vertical)

Best for: counts, comparisons across categories.

```javascript
new Chart(document.getElementById('chart-findings-severity'), {
  type: 'bar',
  data: {
    labels: ['Critical', 'High', 'Medium', 'Low'],
    datasets: [{
      label: 'Findings',
      data: [2, 5, 8, 3],
      backgroundColor: ['#991b1b', '#9a3412', '#854d0e', '#166534'],
      borderRadius: 2,
      maxBarThickness: 48,
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      title: { display: true, text: 'Findings by severity', align: 'start', font: { size: 13, weight: '600' }, color: '#1a1a1a' }
    },
    scales: {
      y: { beginAtZero: true, title: { display: true, text: 'Count' } },
      x: { title: { display: true, text: 'Severity' } }
    }
  }
});
```

## Horizontal bar

Best for: long category labels, ranked lists.

```javascript
new Chart(document.getElementById('chart-categories'), {
  type: 'bar',
  data: {
    labels: ['Prompt injection', 'Data leakage', 'Jailbreak', 'Auth bypass'],
    datasets: [{ label: 'Findings', data: [4, 3, 2, 1], backgroundColor: PALETTE[0], borderRadius: 2 }]
  },
  options: {
    indexAxis: 'y',
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      x: { beginAtZero: true, title: { display: true, text: 'Count' } }
    }
  }
});
```

## Line chart

Best for: trends over time, version comparisons.

```javascript
new Chart(document.getElementById('chart-trend'), {
  type: 'line',
  data: {
    labels: ['v1.0', 'v1.1', 'v1.2', 'v1.3'],
    datasets: [{
      label: 'Accuracy',
      data: [0.82, 0.85, 0.87, 0.89],
      borderColor: PALETTE[0],
      backgroundColor: 'transparent',
      tension: 0.2,
      pointRadius: 4,
      pointHoverRadius: 6,
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      y: { min: 0, max: 1, title: { display: true, text: 'Score' } },
      x: { title: { display: true, text: 'Version' } }
    }
  }
});
```

## Grouped bar (benchmark comparison)

```javascript
new Chart(document.getElementById('chart-benchmark'), {
  type: 'bar',
  data: {
    labels: ['Accuracy', 'F1', 'Latency (ms)'],
    datasets: [
      { label: 'Model A', data: [0.89, 0.87, 120], backgroundColor: PALETTE[0], borderRadius: 2 },
      { label: 'Model B', data: [0.91, 0.88, 95],  backgroundColor: PALETTE[1], borderRadius: 2 },
    ]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    scales: { y: { beginAtZero: true } }
  }
});
```

## Chart selection guide

| Data shape | Chart type |
| --- | --- |
| Counts by category (≤8 categories) | Vertical bar |
| Counts with long labels | Horizontal bar |
| Trend over time/versions | Line |
| Multiple models × metrics | Grouped bar |
| Part-to-whole (≤5 slices) | Doughnut |
| Two continuous variables | Scatter |
| Distribution | Histogram (bar with binned labels) |

**Avoid:** 3D charts, pie charts with >5 slices, dual y-axes unless explicitly requested, radar charts unless user asks.

## Data from CSV

If user provides CSV, parse in a small inline script or pre-process with Python, then embed as JSON in the HTML. Prefer embedding final chart data — reports should stay self-contained.
