# Public Fitbit dataset — download and use

1. Open https://zenodo.org/records/53894.
2. Download one of the two ZIP archives (March 12–April 11, 2016 or April 12–May 12, 2016).
3. Extract the ZIP and inspect its CSV names and headers before deciding which files to load.
4. Keep the original files unchanged; work on copies.
5. Record the file name, download date, columns, row count, distinct participant/session IDs, date range, missing values and duplicates.
6. Load selected CSVs into staging tables, not directly into the conceptual production schema. Map the raw fields explicitly into normalized observations after validating units and timestamps.

## Important note about DB Fiddle

DB Fiddle is useful for running SQL statements, but it is not a convenient CSV ingestion environment for this multi-file public dataset. The prepared `00_dbfiddle_schema_mysql8.sql` creates the conceptual schema and reference rows; it does not load Fitbit observations. To analyze the real CSV records, use a local MySQL environment with a CSV import feature (for example MySQL Workbench or DBeaver) or another SQL environment that supports file upload/import. Do not claim query results until the CSV rows have been loaded and queries have been executed.
