-- Unified Health: cross-platform wearable data platform
-- MySQL 8.0+
-- This file creates the relational database structure and reference data.
-- It does NOT contain real personal health records.
-- Do not insert real health data without informed user permission and appropriate security controls.

CREATE DATABASE IF NOT EXISTS unified_health
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE unified_health;

-- 1) Application users. Keep demographic fields optional and minimized.
CREATE TABLE IF NOT EXISTS app_users (
    user_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    account_key CHAR(36) NOT NULL,
    country_code CHAR(2) NULL,
    preferred_language VARCHAR(10) NULL,
    timezone_name VARCHAR(64) NULL,
    account_status ENUM('active','inactive','deleted') NOT NULL DEFAULT 'active',
    created_at_utc DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (user_id),
    UNIQUE KEY uq_app_users_account_key (account_key)
) ENGINE=InnoDB;

-- 2) Integration providers / health data platforms.
CREATE TABLE IF NOT EXISTS providers (
    provider_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    provider_code VARCHAR(40) NOT NULL,
    provider_name VARCHAR(100) NOT NULL,
    integration_method ENUM('healthkit','health_connect','vendor_api','manual_import') NOT NULL,
    documentation_url VARCHAR(500) NULL,
    integration_status ENUM('planned','development','available','restricted','retired') NOT NULL DEFAULT 'planned',
    PRIMARY KEY (provider_id),
    UNIQUE KEY uq_providers_code (provider_code)
) ENGINE=InnoDB;

-- 3) Device catalog: product families / models supported by the platform.
CREATE TABLE IF NOT EXISTS device_models (
    model_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    provider_id SMALLINT UNSIGNED NOT NULL,
    model_name VARCHAR(120) NOT NULL,
    device_type ENUM('smartwatch','smart_ring','fitness_tracker','phone_health_platform','other') NOT NULL,
    compatibility_notes VARCHAR(1000) NULL,
    PRIMARY KEY (model_id),
    UNIQUE KEY uq_device_model_provider_name (provider_id, model_name),
    CONSTRAINT fk_device_models_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
) ENGINE=InnoDB;

-- 4) A user's registered wearable devices.
CREATE TABLE IF NOT EXISTS user_devices (
    device_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    model_id BIGINT UNSIGNED NOT NULL,
    device_alias VARCHAR(100) NULL,
    platform_os ENUM('ios','android','other') NULL,
    connected_at_utc DATETIME(3) NULL,
    disconnected_at_utc DATETIME(3) NULL,
    device_status ENUM('connected','disconnected','error','retired') NOT NULL DEFAULT 'connected',
    PRIMARY KEY (device_id),
    KEY ix_user_devices_user (user_id),
    CONSTRAINT fk_user_devices_user FOREIGN KEY (user_id) REFERENCES app_users(user_id),
    CONSTRAINT fk_user_devices_model FOREIGN KEY (model_id) REFERENCES device_models(model_id)
) ENGINE=InnoDB;

-- 5) Provider connections and authorization state.
-- Never store raw OAuth client secrets or long-lived access tokens in this table.
-- Store secret-manager references only.
CREATE TABLE IF NOT EXISTS provider_connections (
    connection_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    provider_id SMALLINT UNSIGNED NOT NULL,
    connection_method ENUM('healthkit','health_connect','vendor_oauth','file_import') NOT NULL,
    external_account_ref VARCHAR(255) NULL,
    secret_reference VARCHAR(255) NULL,
    granted_scopes JSON NULL,
    connection_status ENUM('pending','connected','expired','revoked','error') NOT NULL DEFAULT 'pending',
    authorized_at_utc DATETIME(3) NULL,
    revoked_at_utc DATETIME(3) NULL,
    last_successful_sync_utc DATETIME(3) NULL,
    last_error_code VARCHAR(80) NULL,
    created_at_utc DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (connection_id),
    KEY ix_connections_user_provider (user_id, provider_id),
    CONSTRAINT fk_connections_user FOREIGN KEY (user_id) REFERENCES app_users(user_id),
    CONSTRAINT fk_connections_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
) ENGINE=InnoDB;

-- 6) Standard metric dictionary. Canonical units allow cross-provider normalization.
CREATE TABLE IF NOT EXISTS metric_types (
    metric_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    metric_code VARCHAR(50) NOT NULL,
    metric_name VARCHAR(120) NOT NULL,
    metric_category ENUM('activity','cardiovascular','sleep','respiratory','temperature','recovery','body_measurement','nutrition','other') NOT NULL,
    canonical_unit VARCHAR(30) NOT NULL,
    description VARCHAR(500) NULL,
    is_health_sensitive BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (metric_id),
    UNIQUE KEY uq_metric_code (metric_code)
) ENGINE=InnoDB;

-- 7) Mapping of each vendor's metric names/units to the platform's canonical dictionary.
-- Use this to document incompatible definitions and prevent false like-for-like comparisons.
CREATE TABLE IF NOT EXISTS provider_metric_mappings (
    mapping_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    provider_id SMALLINT UNSIGNED NOT NULL,
    provider_metric_code VARCHAR(100) NOT NULL,
    metric_id SMALLINT UNSIGNED NOT NULL,
    provider_unit VARCHAR(30) NULL,
    canonical_unit VARCHAR(30) NOT NULL,
    transform_rule VARCHAR(500) NULL,
    comparability_note VARCHAR(1000) NULL,
    mapping_status ENUM('proposed','verified','not_comparable','retired') NOT NULL DEFAULT 'proposed',
    verified_at_utc DATETIME(3) NULL,
    PRIMARY KEY (mapping_id),
    UNIQUE KEY uq_provider_metric_code (provider_id, provider_metric_code),
    CONSTRAINT fk_metric_map_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    CONSTRAINT fk_metric_map_metric FOREIGN KEY (metric_id) REFERENCES metric_types(metric_id)
) ENGINE=InnoDB;

-- 7) Normalized observations from connected sources.
-- Preserve provider/device provenance and original units. Do not silently merge conflicting sources.
CREATE TABLE IF NOT EXISTS health_observations (
    observation_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    provider_id SMALLINT UNSIGNED NOT NULL,
    device_id BIGINT UNSIGNED NULL,
    metric_id SMALLINT UNSIGNED NOT NULL,
    source_record_key VARCHAR(255) NULL,
    observed_start_utc DATETIME(3) NOT NULL,
    observed_end_utc DATETIME(3) NULL,
    value_numeric DECIMAL(18,6) NULL,
    value_text VARCHAR(255) NULL,
    original_unit VARCHAR(30) NULL,
    canonical_value DECIMAL(18,6) NULL,
    canonical_unit VARCHAR(30) NULL,
    source_timezone VARCHAR(64) NULL,
    data_quality_status ENUM('valid','suspected_duplicate','incomplete','out_of_range','needs_review') NOT NULL DEFAULT 'valid',
    ingested_at_utc DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    raw_payload_reference VARCHAR(500) NULL,
    PRIMARY KEY (observation_id),
    UNIQUE KEY uq_provider_source_record (provider_id, source_record_key),
    KEY ix_observations_user_metric_time (user_id, metric_id, observed_start_utc),
    KEY ix_observations_device_time (device_id, observed_start_utc),
    CONSTRAINT fk_observations_user FOREIGN KEY (user_id) REFERENCES app_users(user_id),
    CONSTRAINT fk_observations_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    CONSTRAINT fk_observations_device FOREIGN KEY (device_id) REFERENCES user_devices(device_id),
    CONSTRAINT fk_observations_metric FOREIGN KEY (metric_id) REFERENCES metric_types(metric_id)
) ENGINE=InnoDB;

-- 8) Optional normalized workout / activity sessions.
CREATE TABLE IF NOT EXISTS activity_sessions (
    activity_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    provider_id SMALLINT UNSIGNED NOT NULL,
    device_id BIGINT UNSIGNED NULL,
    source_activity_key VARCHAR(255) NULL,
    activity_type VARCHAR(80) NOT NULL,
    started_at_utc DATETIME(3) NOT NULL,
    ended_at_utc DATETIME(3) NULL,
    duration_seconds INT UNSIGNED NULL,
    distance_meters DECIMAL(12,2) NULL,
    active_calories_kcal DECIMAL(12,2) NULL,
    average_heart_rate_bpm DECIMAL(7,2) NULL,
    max_heart_rate_bpm DECIMAL(7,2) NULL,
    PRIMARY KEY (activity_id),
    UNIQUE KEY uq_provider_activity (provider_id, source_activity_key),
    KEY ix_activity_user_started (user_id, started_at_utc),
    CONSTRAINT fk_activity_user FOREIGN KEY (user_id) REFERENCES app_users(user_id),
    CONSTRAINT fk_activity_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    CONSTRAINT fk_activity_device FOREIGN KEY (device_id) REFERENCES user_devices(device_id)
) ENGINE=InnoDB;

-- 9) Sleep sessions with source attribution.
CREATE TABLE IF NOT EXISTS sleep_sessions (
    sleep_session_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    provider_id SMALLINT UNSIGNED NOT NULL,
    device_id BIGINT UNSIGNED NULL,
    source_session_key VARCHAR(255) NULL,
    sleep_start_utc DATETIME(3) NOT NULL,
    sleep_end_utc DATETIME(3) NOT NULL,
    total_sleep_minutes SMALLINT UNSIGNED NULL,
    sleep_score DECIMAL(6,2) NULL,
    sleep_efficiency_pct DECIMAL(5,2) NULL,
    PRIMARY KEY (sleep_session_id),
    UNIQUE KEY uq_provider_sleep_session (provider_id, source_session_key),
    KEY ix_sleep_user_start (user_id, sleep_start_utc),
    CONSTRAINT fk_sleep_user FOREIGN KEY (user_id) REFERENCES app_users(user_id),
    CONSTRAINT fk_sleep_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    CONSTRAINT fk_sleep_device FOREIGN KEY (device_id) REFERENCES user_devices(device_id),
    CONSTRAINT chk_sleep_times CHECK (sleep_end_utc > sleep_start_utc)
) ENGINE=InnoDB;

-- 10) Fine-grained consent records. Permissions can be revoked independently by data category.
CREATE TABLE IF NOT EXISTS consent_records (
    consent_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    provider_id SMALLINT UNSIGNED NULL,
    data_category VARCHAR(80) NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    consent_status ENUM('granted','denied','revoked','expired') NOT NULL,
    consented_at_utc DATETIME(3) NOT NULL,
    withdrawn_at_utc DATETIME(3) NULL,
    consent_notice_version VARCHAR(40) NOT NULL,
    PRIMARY KEY (consent_id),
    KEY ix_consent_user_category (user_id, data_category, consented_at_utc),
    CONSTRAINT fk_consent_user FOREIGN KEY (user_id) REFERENCES app_users(user_id),
    CONSTRAINT fk_consent_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
) ENGINE=InnoDB;

-- 11) Sync history and diagnostics.
CREATE TABLE IF NOT EXISTS sync_runs (
    sync_run_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    connection_id BIGINT UNSIGNED NOT NULL,
    started_at_utc DATETIME(3) NOT NULL,
    completed_at_utc DATETIME(3) NULL,
    sync_status ENUM('running','success','partial','failed') NOT NULL,
    records_received INT UNSIGNED NOT NULL DEFAULT 0,
    records_inserted INT UNSIGNED NOT NULL DEFAULT 0,
    records_skipped INT UNSIGNED NOT NULL DEFAULT 0,
    records_rejected INT UNSIGNED NOT NULL DEFAULT 0,
    error_code VARCHAR(80) NULL,
    error_summary VARCHAR(500) NULL,
    PRIMARY KEY (sync_run_id),
    KEY ix_sync_connection_started (connection_id, started_at_utc),
    CONSTRAINT fk_sync_connection FOREIGN KEY (connection_id) REFERENCES provider_connections(connection_id)
) ENGINE=InnoDB;

-- 12) Explainable insights generated from normalized data.
-- This table is for wellness information, not diagnosis or emergency detection.
CREATE TABLE IF NOT EXISTS health_insights (
    insight_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    insight_type VARCHAR(80) NOT NULL,
    title VARCHAR(180) NOT NULL,
    explanation TEXT NOT NULL,
    evidence_start_utc DATETIME(3) NULL,
    evidence_end_utc DATETIME(3) NULL,
    source_metric_codes JSON NULL,
    rule_or_model_version VARCHAR(80) NOT NULL,
    confidence_label ENUM('low','moderate','high','not_assessed') NOT NULL DEFAULT 'not_assessed',
    created_at_utc DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    dismissed_at_utc DATETIME(3) NULL,
    PRIMARY KEY (insight_id),
    KEY ix_insights_user_created (user_id, created_at_utc),
    CONSTRAINT fk_insights_user FOREIGN KEY (user_id) REFERENCES app_users(user_id)
) ENGINE=InnoDB;

-- Reference records: providers and metrics. These are metadata, not user health records.
INSERT INTO providers (provider_code, provider_name, integration_method, documentation_url, integration_status)
VALUES
 ('APPLE_HEALTH','Apple Health / HealthKit','healthkit','https://developer.apple.com/documentation/healthkit/','development'),
 ('ANDROID_HEALTH_CONNECT','Android Health Connect','health_connect','https://developer.android.com/health-and-fitness/health-connect','development'),
 ('OURA','Oura','vendor_api','https://cloud.ouraring.com/docs/','planned'),
 ('RINGCONN','RingConn','health_connect','https://ringconn.com/pages/ringconn-app-privacy-policy','planned'),
 ('GARMIN','Garmin Connect','vendor_api','https://developer.garmin.com/gc-developer-program/overview/','planned'),
 ('WHOOP','WHOOP','vendor_api','https://developer.whoop.com/api/','planned'),
 ('GOOGLE_HEALTH','Google Health API','vendor_api','https://developers.google.com/health/about','planned'),
 ('SAMSUNG_HEALTH','Samsung Health','health_connect','https://developer.android.com/health-and-fitness/health-connect','planned')
ON DUPLICATE KEY UPDATE provider_name = VALUES(provider_name);

INSERT INTO metric_types (metric_code, metric_name, metric_category, canonical_unit, description)
VALUES
 ('STEPS','Steps','activity','count','Total step count over a time interval.'),
 ('HEART_RATE','Heart rate','cardiovascular','bpm','Heart rate in beats per minute.'),
 ('RESTING_HEART_RATE','Resting heart rate','cardiovascular','bpm','Resting heart rate in beats per minute.'),
 ('HRV','Heart rate variability','cardiovascular','ms','HRV measurement; methods and windows can vary by provider.'),
 ('SPO2','Blood oxygen saturation','respiratory','percent','Oxygen saturation percentage, when exposed by source.'),
 ('RESPIRATORY_RATE','Respiratory rate','respiratory','breaths_per_minute','Breaths per minute.'),
 ('SKIN_TEMPERATURE_DELTA','Skin temperature deviation','temperature','celsius_delta','Deviation from a device/user baseline; not core body temperature.'),
 ('SLEEP_DURATION','Sleep duration','sleep','minutes','Total sleep duration for a sleep session.'),
 ('SLEEP_SCORE','Sleep score','sleep','score','Provider-defined score; not directly comparable across providers.'),
 ('ACTIVE_CALORIES','Active calories','activity','kcal','Estimated active energy expenditure.'),
 ('STRESS_SCORE','Stress score','recovery','score','Provider-defined stress indicator; not directly comparable across providers.'),
 ('RECOVERY_SCORE','Recovery score','recovery','score','Provider-defined recovery/readiness indicator; not directly comparable across providers.')
ON DUPLICATE KEY UPDATE metric_name = VALUES(metric_name);

-- Example analytical query 1: Daily steps by user and source.
-- Results only appear after authorized source records have been ingested.
-- SELECT
--   ho.user_id,
--   DATE(ho.observed_start_utc) AS observation_date_utc,
--   p.provider_name,
--   SUM(ho.canonical_value) AS total_steps
-- FROM health_observations ho
-- JOIN metric_types mt ON mt.metric_id = ho.metric_id
-- JOIN providers p ON p.provider_id = ho.provider_id
-- WHERE mt.metric_code = 'STEPS'
--   AND ho.data_quality_status = 'valid'
-- GROUP BY ho.user_id, DATE(ho.observed_start_utc), p.provider_name
-- ORDER BY observation_date_utc, ho.user_id;

-- Example analytical query 2: Compare metric coverage by provider.
-- SELECT p.provider_name, mt.metric_name, COUNT(*) AS observation_count,
--        MIN(ho.observed_start_utc) AS first_seen_utc,
--        MAX(ho.observed_start_utc) AS last_seen_utc
-- FROM health_observations ho
-- JOIN providers p ON p.provider_id = ho.provider_id
-- JOIN metric_types mt ON mt.metric_id = ho.metric_id
-- GROUP BY p.provider_name, mt.metric_name
-- ORDER BY p.provider_name, observation_count DESC;

-- Example analytical query 3: Find possible duplicate observations across providers.
-- This flags same-user, same-metric records within a 60-second window for review;
-- it does NOT automatically delete or average them.
-- SELECT a.user_id, ma.metric_code, a.observation_id AS obs_a,
--        b.observation_id AS obs_b, a.provider_id AS source_a, b.provider_id AS source_b,
--        a.observed_start_utc
-- FROM health_observations a
-- JOIN health_observations b
--   ON b.user_id = a.user_id
--  AND b.metric_id = a.metric_id
--  AND b.observation_id > a.observation_id
--  AND ABS(TIMESTAMPDIFF(SECOND, a.observed_start_utc, b.observed_start_utc)) <= 60
-- JOIN metric_types ma ON ma.metric_id = a.metric_id
-- WHERE a.data_quality_status = 'valid'
--   AND b.data_quality_status = 'valid';


-- Example analytical query 4: User-level daily metric summary (illustrative template).
-- Keep each provider separate until metric definitions and source overlap are validated.
-- SELECT ho.user_id, DATE(ho.observed_start_utc) AS metric_date,
--        p.provider_name, mt.metric_code,
--        AVG(ho.canonical_value) AS avg_value,
--        MIN(ho.canonical_value) AS min_value,
--        MAX(ho.canonical_value) AS max_value,
--        COUNT(*) AS observations
-- FROM health_observations ho
-- JOIN providers p ON p.provider_id = ho.provider_id
-- JOIN metric_types mt ON mt.metric_id = ho.metric_id
-- WHERE ho.data_quality_status = 'valid'
-- GROUP BY ho.user_id, DATE(ho.observed_start_utc), p.provider_name, mt.metric_code;

-- Example analytical query 5: Connection reliability by provider.
-- SELECT p.provider_name,
--        COUNT(*) AS sync_attempts,
--        SUM(sr.sync_status = 'success') AS successful_syncs,
--        SUM(sr.sync_status IN ('partial','failed')) AS incomplete_or_failed_syncs,
--        ROUND(100 * SUM(sr.sync_status = 'success') / NULLIF(COUNT(*),0), 1) AS success_rate_pct
-- FROM sync_runs sr
-- JOIN provider_connections pc ON pc.connection_id = sr.connection_id
-- JOIN providers p ON p.provider_id = pc.provider_id
-- GROUP BY p.provider_name
-- ORDER BY success_rate_pct DESC;
