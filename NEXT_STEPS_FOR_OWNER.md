# What you need to do next

You do not need to build the website from scratch. The main portfolio page and project folder are prepared.

## Do these two things first

### A. Publish the website

Follow the GitHub Pages steps in `README.md`. This is the one public URL you can add to LinkedIn and your resume. If you do not want to use GitHub, you can use the `index.html` content as a Notion page instead.

### B. Complete the real-data proof

1. Open the Zenodo dataset page: https://zenodo.org/records/53894
2. Download one of the Fitbit ZIP files and extract its CSVs.
3. Inspect the CSV names, columns, participant identifiers and date coverage.
4. Execute `sql/01_unified_health_schema_mysql.sql` in MySQL 8.
5. Load appropriate Fitbit CSVs into staging tables. The normalized product schema is a conceptual target and will need an explicit mapping step.
6. Run and validate queries; do not claim results until you have executed them.
7. Build the Tableau dashboard from validated aggregates.

## What I prepared for you

- One-page public portfolio website (`index.html`).
- MySQL schema and analyst query templates.
- Requirements and acceptance criteria.
- Customer journey, data flow and ERD diagrams.
- Jira backlog CSV template.
- Confluence starter pages.
- Research workbooks and public-source notes.

## What I cannot truthfully mark complete yet

- A live GitHub Pages website under your account.
- A populated SQL database with real Fitbit observations.
- Executed SQL results and completed Excel analysis.
- A live Tableau dashboard published under your account.
- Actual Jira and Confluence projects in your accounts.

Those require your accounts / local environment and, for data analysis, the downloaded CSV files. This project package is structured so those are the remaining steps—not a blank start.
