# Requirements and acceptance criteria

## Functional requirements

| ID | Requirement | Acceptance criteria |
|---|---|---|
| FR-01 | User can create an account and access the platform on supported clients. | Account is created; a user can sign in on a supported web client. |
| FR-02 | User can view available device connection options. | Options are filtered by client OS and documented integration capability. |
| FR-03 | User can grant permissions by data category. | Permission purpose and categories are shown before authorization; no data is read before permission. |
| FR-04 | User can disconnect a source and revoke access. | Connection status changes and future sync jobs stop; stored-data handling follows the disclosed policy. |
| FR-05 | System records source, timestamp, unit and device provenance for each observation. | Every stored observation can be traced to provider and original unit. |
| FR-06 | System displays data availability and last successful sync. | User can see last sync time, partial coverage and connection errors. |
| FR-07 | System flags conflicting or potentially duplicate records. | Flag is visible for review; conflicting records are not silently averaged. |
| FR-08 | User can view trends for supported metrics. | Charts label the metric, unit, time range and source. |
| FR-09 | System displays plain-language wellness insights. | Each insight identifies evidence window, source metrics, rule/model version and confidence level. |
| FR-10 | User can request account/data deletion. | Request is logged and processed according to retention and legal requirements. |

## Non-functional requirements

- Security: encryption in transit and at rest, secret management, least privilege and audit logging.
- Privacy: purpose limitation, granular consent, minimization, retention controls and deletion.
- Availability: failed provider syncs are retried safely and surfaced to the user.
- Data quality: original units and timestamps are preserved; normalizations are versioned.
- Accessibility: readable language, keyboard support and accessible chart labels.
- Interoperability: client and provider limitations are documented and tested.

## Example user story

As a wearable user, I want to connect a supported device or health platform so that I can view the health measurements I authorize in one place.

### Acceptance criteria

1. The app explains which categories it requests and why.
2. The user can approve or decline each supported category.
3. If access is declined, the app does not imply that data was retrieved.
4. Imported records retain their source, timestamp and unit.
5. Unsupported metrics are marked unavailable rather than shown as zero.

## Important product boundary

These are proposed requirements for a portfolio case study, not proof of implementation or regulatory compliance.
