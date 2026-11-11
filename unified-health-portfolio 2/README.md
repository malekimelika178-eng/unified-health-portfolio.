# Unified Health — Business Analyst Portfolio Case Study

This is a ready-to-publish static portfolio site for a proposed cross-platform wearable-health companion.

## Important status statement

This is a proposed product and business analysis case study, not a launched or working commercial application. The site distinguishes drafted deliverables from work still to be executed (real data load, SQL validation, Excel analysis, Tableau dashboard and live Jira/Confluence workspaces).

## Preview locally

Open `index.html` in a web browser. Keep the `assets`, `sql`, `data`, `business-analysis`, `jira` and `confluence` folders in the same directory so links work.

## Publish as a public portfolio with GitHub Pages

1. Create or sign into a GitHub account.
2. Create a new **public** repository named `unified-health-portfolio`.
3. Upload the contents of this folder to the repository root (not the ZIP itself).
4. Open repository **Settings → Pages**.
5. Under Build and deployment, choose **Deploy from a branch**.
6. Select branch `main` and folder `/ (root)`, then Save.
7. Wait for GitHub Pages to publish and use the generated `https://<username>.github.io/unified-health-portfolio/` URL in LinkedIn.

Do not publish real personal health records, access tokens, passwords or private information. This package contains no individual-level live health records.

## Contents

- `index.html`: Portfolio landing page / case study.
- `sql/`: MySQL schema, query templates, data dictionary and integration matrix.
- `assets/diagrams/`: PNG/SVG previews and editable `.drawio` diagrams.
- `business-analysis/`: Project brief, requirements and acceptance criteria.
- `jira/`: CSV backlog template, suitable for mapping during Jira import.
- `confluence/`: Markdown pages that can be pasted/imported into a Confluence space.
- `research/`: Working Excel research files; source validation is still required before publishing any numeric claims.
- `data/`: Dataset source and limitations notes.

## Public data source

Zenodo: https://zenodo.org/records/53894 — 30 eligible Fitbit users consented to submit tracker data collected in 2016, including physical activity, heart rate and sleep. This sample is small, historical and Fitbit-only; it is not representative of all wearable users and does not validate other integrations.

## Recommended finalization order

1. Download the public Zenodo data and inspect its CSVs.
2. Execute the MySQL schema and import suitable Fitbit tables into staging tables.
3. Validate and run the analysis queries; document row counts, missingness and date range.
4. Build an Excel analysis workbook with traceable formulas and sources.
5. Build a Tableau dashboard from validated outputs; publish only aggregated, non-identifying results.
6. Import the backlog into Jira and create Confluence pages in your own accounts.
7. Update the status table on `index.html` to reflect what you have actually completed.

## Responsible research

- Do not infer sensitive demographics from public usernames or reviews.
- Do not claim all wearable brands expose all data.
- Preserve provider, timestamp and unit for each reading.
- Do not compare proprietary scores (e.g. readiness, stress, recovery) as equivalent without verifying definitions.
- Treat wellness insights as informational, not diagnostic.
