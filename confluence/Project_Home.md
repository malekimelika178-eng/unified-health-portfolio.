# Unified Health — Project Home

**Project status:** Portfolio case study / proposed product. Not a launched application.

## Purpose

Investigate and specify a cross-platform wearable-health companion that provides source-transparent, permissioned health information and understandable personal trends.

## Current workstreams

1. Market and competitor research.
2. Customer pain-point research from public reviews and discussions.
3. Product requirements and MVP scope.
4. Integration architecture and device capability mapping.
5. Data model and SQL analysis using a public historical wearable dataset.
6. Tableau reporting and portfolio publication.

## Key decisions

- Target iOS and Android mobile experiences, plus a responsive web interface for Mac and Windows.
- Use HealthKit and Health Connect as potential OS-level integration pathways.
- Treat direct vendor APIs as conditional on vendor approval, access and supported metrics.
- Preserve source provenance, units and timestamps.
- Do not infer medical status or use health data for diagnosis.

## Risks

- Third-party API access can be restricted or require partner approval.
- Metrics may use incompatible definitions or units.
- Historical Fitbit sample is small and not representative.
- Health information requires strong privacy, security and consent design.
