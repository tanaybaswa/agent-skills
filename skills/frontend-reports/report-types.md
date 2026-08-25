# Report Type Templates

Standard section structures. Adapt to content — omit empty sections, never pad with filler.

---

## Red Team / Security Assessment

```
1. Title block
2. Executive summary (3–5 sentences: scope, highest severity, overall posture)
3. Scope & objectives
   - Target systems, date range, rules of engagement
4. Methodology
   - Attack vectors tested, tools, constraints
5. Summary metrics (metric-grid)
   - Findings count by severity, tests run, coverage %
6. Findings
   - Table: ID | Severity | Category | Title | Status
   - Detail each Critical/High finding: description, evidence, impact, recommendation
7. Recommendations (prioritized list)
8. Appendix: full finding list, test matrix, glossary
```

**Charts to consider:** findings by severity (bar), findings by category (horizontal bar), timeline of discovery (optional).

---

## Dataset Documentation

```
1. Title block
2. Overview (purpose, owner, last updated, version)
3. Summary metrics
   - Row count, column count, size, date range, missing % overall
4. Schema
   - Table: column | type | description | nullable | example
5. Data quality
   - Completeness, duplicates, outliers, validation rules
6. Distributions
   - Charts for key numeric/categorical columns
7. Known limitations & bias
8. Lineage & provenance (sources, transformations, PII handling)
9. Appendix: sample rows, full enum values, change log
```

**Charts to consider:** missing values by column (bar), class balance (bar), numeric histograms, time-series volume.

---

## Model System Card

Follow structure inspired by Model Cards (Mitchell et al.) — adapted for customer delivery:

```
1. Title block (model name, version, date, provider)
2. Model overview (1 paragraph: what it does, model type, modality)
3. Intended use
   - Primary uses, intended users, out-of-scope uses
4. Performance metrics (metric-grid + table)
   - Benchmark results with dataset/version noted
5. Training data (summary — not proprietary detail unless provided)
   - Source, size, date range, known gaps
6. Evaluation methodology
7. Limitations & risks
8. Ethical considerations & mitigations
9. Version history
10. Contact / support
```

**Charts to consider:** benchmark comparison (grouped bar), metric trend across versions (line), confusion matrix (table heatmap as HTML table, not chart).

---

## Evaluation / Benchmark Summary

```
1. Title block
2. Executive summary
3. Test setup (models/systems compared, datasets, metrics, hardware)
4. Results overview (metric-grid)
5. Detailed results (table + charts)
6. Analysis (where differences matter, statistical notes)
7. Conclusions & recommendations
8. Appendix: raw scores, config, reproducibility notes
```

**Charts to consider:** grouped bar (models × metrics), radar only if ≤6 metrics and user requests it, latency vs quality scatter.

---

## Custom Reports

For undefined types, derive structure from:

1. What decision should the reader make after reading?
2. What evidence supports that decision? (tables, charts, findings)
3. What context is mandatory for interpretation? (scope, methodology, limitations)

Default skeleton: title → summary → context → evidence → conclusions → appendix.
