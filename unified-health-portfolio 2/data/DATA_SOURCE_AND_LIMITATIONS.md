# Data sources and limitations

## Public wearable dataset selected for the technical demonstration

**Crowd-sourced Fitbit datasets, 12 March–12 May 2016**  
Zenodo record: https://zenodo.org/records/53894  
DOI: https://doi.org/10.5281/zenodo.53894

The original Zenodo record states that 30 eligible Fitbit users consented to submit personal tracker data, including minute-level physical activity, heart-rate and sleep monitoring. It contains two ZIP archives covering 12 March–11 April 2016 and 12 April–12 May 2016.

### Appropriate use in this project

- Demonstrate the structure of wearable data.
- Practice CSV inspection, cleaning, SQL staging, aggregation and dashboarding.
- Explore steps, activity minutes, heart rate and sleep patterns within this small historical sample.

### Limitations to disclose

- 30 participants only; not representative of global wearable users.
- Historical data from 2016; not current market behavior.
- Fitbit-only; it does not validate integrations with Apple Watch, Oura, RingConn, Garmin or WHOOP.
- No reliable age, occupation or global demographic profile is included in the Zenodo description.
- It does not provide private feature-usage analytics from wearable apps.
- Health metrics are observational; do not infer medical conditions or make clinical claims.

## Competitor and integration research sources

- Apple HealthKit overview: https://developer.apple.com/documentation/healthkit
- HealthKit authorization: https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data
- Android Health Connect: https://developer.android.com/health-and-fitness/health-connect
- Google Health: https://support.google.com/googlehealth/answer/14236613
- Oura API documentation: https://cloud.ouraring.com/docs/
- Garmin Connect Developer Program: https://developer.garmin.com/gc-developer-program/overview/
- WHOOP API: https://developer.whoop.com/api/

## Research integrity rules

1. Record the date, country/storefront, and currency for every app rating or price.
2. Treat public reviews and Reddit posts as self-selected qualitative evidence, not a representative survey.
3. Do not infer age, gender, occupation, ethnicity, medical status, or other sensitive attributes from usernames, photos, or writing style.
4. Distinguish documented integrations from proposed integrations and unverified assumptions.
5. Do not claim every metric is available through every provider. Permissions, API access, platform, device model, subscription and regional restrictions may apply.
