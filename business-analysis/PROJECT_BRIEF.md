# Unified Health — Business Analysis Case Study

## Project type

Proposed product / business analysis case study. No commercial application has been built or launched.

## Business problem

People who use multiple wearable ecosystems may find their health information fragmented across vendor apps and data sources. The project investigates whether a cross-platform companion could provide a clearer, more transparent view of compatible health information.

## Proposed product

A cross-platform health-information companion that can receive selected, permissioned data from supported device ecosystems, preserve source attribution, explain unavailable or non-comparable measurements, and present personal trends in an accessible way.

## Target users

- Everyday consumers who use one or more compatible wearables.
- People who want to understand personal activity, sleep and wellness trends.
- Secondary: coaches or wellness professionals, subject to consent and access controls.

## Product principles

1. User control and granular permissions.
2. Device/platform compatibility stated accurately.
3. Source attribution for every observation.
4. No silent merging of conflicting values.
5. Plain-language explanations of trends and data gaps.
6. Wellness support, not diagnosis or emergency detection.
7. Data minimization, security, deletion and revocation built into the design.

## MVP proposal

- Responsive web dashboard for viewing a user's account and synchronized trends.
- Native mobile integration layer: HealthKit on iOS and Health Connect on Android.
- Initial metric set: steps, activity duration, heart rate, sleep duration and selected additional metrics where supported.
- Connection status, last sync, missing-data and source labels.
- Simple personal-baseline trend summaries.
- User controls to connect/disconnect sources and revoke permissions.

Direct integrations with Oura, Garmin or WHOOP are future/conditional workstreams requiring provider review, developer access and product approval where applicable. RingConn coverage depends on its currently supported Apple Health / Health Connect exports and specific metrics.

## Out of scope for MVP

- Diagnosing disease or making medical treatment recommendations.
- Guaranteeing every metric from every wearable.
- Replacing vendor apps or firmware.
- Building custom wearable hardware.
- Clinical record aggregation.
- Fully automated AI health advice without clinical, safety, privacy and regulatory review.

## Business analysis questions

- Which device ecosystems can be supported through standard health platforms?
- Which measurements are available, and are they comparable across providers?
- Where do users experience missing data, sync friction or unclear insights?
- What minimum set of features creates a useful first release?
- What privacy, security and consent controls are required?

## Key assumptions to validate

- Customers experience meaningful fragmentation across their current apps.
- They value a source-transparent, multi-device view.
- Device platforms provide enough authorized data for a useful MVP.
- Users understand and trust comparative trend explanations.

## Success measures to define and test

- Successful connection rate by integration route.
- Sync success rate and data freshness.
- Percentage of supported observations with source and unit metadata.
- User-reported usefulness and clarity of insights.
- Weekly active use and retention (once tested with real product users).
- Permission revocation and data deletion completion rates.

No target values are claimed until a product baseline or user study exists.
