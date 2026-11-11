-- Unified Health — analyst query examples (MySQL 8+)
-- Run these after loading a documented dataset into the normalized tables.
-- The examples below assume real observations have been ingested; the starter schema itself has no user readings.
USE unified_health;

-- 1. Which metric types are available from each provider in the loaded dataset?
SELECT p.provider_name, mt.metric_code, mt.metric_name,
       COUNT(*) AS observation_count,
       MIN(ho.observed_start_utc) AS first_observation_utc,
       MAX(ho.observed_start_utc) AS last_observation_utc
FROM health_observations ho
JOIN providers p ON p.provider_id = ho.provider_id
JOIN metric_types mt ON mt.metric_id = ho.metric_id
WHERE ho.data_quality_status = 'valid'
GROUP BY p.provider_name, mt.metric_code, mt.metric_name
ORDER BY p.provider_name, observation_count DESC;

-- 2. Average daily steps by user and source.
-- Use this only if source values have been normalized to daily step totals.
SELECT ho.user_id, DATE(ho.observed_start_utc) AS local_or_utc_date,
       p.provider_name, SUM(ho.canonical_value) AS daily_steps
FROM health_observations ho
JOIN metric_types mt ON mt.metric_id = ho.metric_id
JOIN providers p ON p.provider_id = ho.provider_id
WHERE mt.metric_code = 'STEPS'
  AND ho.data_quality_status = 'valid'
GROUP BY ho.user_id, DATE(ho.observed_start_utc), p.provider_name
ORDER BY ho.user_id, local_or_utc_date;

-- 3. Average sleep duration by user and source (hours).
SELECT ss.user_id, p.provider_name,
       ROUND(AVG(ss.total_sleep_minutes) / 60, 2) AS avg_sleep_hours,
       COUNT(*) AS sleep_sessions
FROM sleep_sessions ss
JOIN providers p ON p.provider_id = ss.provider_id
GROUP BY ss.user_id, p.provider_name
ORDER BY ss.user_id, p.provider_name;

-- 4. Sync reliability by provider.
SELECT p.provider_name,
       COUNT(*) AS sync_attempts,
       SUM(sr.sync_status = 'success') AS successful_syncs,
       SUM(sr.sync_status IN ('partial','failed')) AS incomplete_or_failed_syncs,
       ROUND(100 * SUM(sr.sync_status = 'success') / NULLIF(COUNT(*), 0), 1) AS success_rate_pct
FROM sync_runs sr
JOIN provider_connections pc ON pc.connection_id = sr.connection_id
JOIN providers p ON p.provider_id = pc.provider_id
GROUP BY p.provider_name
ORDER BY success_rate_pct DESC;

-- 5. Find potential cross-provider duplicate readings for review.
-- A time match is only a flag for investigation, not proof that two values are duplicates.
SELECT a.user_id, mt.metric_code,
       a.observation_id AS observation_a,
       b.observation_id AS observation_b,
       pa.provider_name AS source_a,
       pb.provider_name AS source_b,
       a.observed_start_utc,
       a.canonical_value AS value_a,
       b.canonical_value AS value_b
FROM health_observations a
JOIN health_observations b
  ON b.user_id = a.user_id
 AND b.metric_id = a.metric_id
 AND b.observation_id > a.observation_id
 AND ABS(TIMESTAMPDIFF(SECOND, a.observed_start_utc, b.observed_start_utc)) <= 60
JOIN metric_types mt ON mt.metric_id = a.metric_id
JOIN providers pa ON pa.provider_id = a.provider_id
JOIN providers pb ON pb.provider_id = b.provider_id
WHERE a.data_quality_status = 'valid'
  AND b.data_quality_status = 'valid';

-- 6. Show metrics with provider-specific definitions that are not approved for comparison.
SELECT p.provider_name, pmm.provider_metric_code,
       mt.metric_code, pmm.provider_unit, pmm.canonical_unit,
       pmm.mapping_status, pmm.comparability_note
FROM provider_metric_mappings pmm
JOIN providers p ON p.provider_id = pmm.provider_id
JOIN metric_types mt ON mt.metric_id = pmm.metric_id
WHERE pmm.mapping_status IN ('proposed','not_comparable')
ORDER BY p.provider_name, mt.metric_code;
