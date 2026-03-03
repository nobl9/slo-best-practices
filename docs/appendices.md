# 10. Appendices


## 10.1 Appendix A: SLO Specification Template


| Field | Value |
| --- | --- |
| SLO Name | [e.g., payments-api-availability] |
| Display Name | [e.g., Payments API Availability] |
| Service | [e.g., payments-api] |
| Project | [e.g., checkout-team] |
| SLI Description | [e.g., Percentage of HTTP requests returning 2xx/3xx] |
| SLI Type | [Availability / Latency / Throughput / Correctness] |
| Metric Source | [e.g., Datadog, query: sum:http.requests.success{...}] |
| Budgeting Method | [Occurrences / Time Slices] |
| Target | [e.g., 99.9%] |
| Time Window | [e.g., 30-day rolling / Monthly calendar-aligned] |
| Layer | [User Journey / Application / Service / Platform / Infrastructure / Dependency] |
| Tier | [Critical / High / Medium / Low] |
| Owner | [e.g., checkout-backend@company.com] |
| Error Budget Policy | [Link to policy document] |
| Alert Policies | [Fast-burn: 20x/5min, Slow-burn: 2x/6hr, Budget: 25%, 10%] |
| No-Data Alert | [Threshold: 5 min, Method: PagerDuty + Slack] |
| Review Cadence | [Weekly operational, Monthly target review] |
| Labels | [team: checkout, tier: critical, layer: application, env: production] |
| Annotations | [runbook: ..., oncall: ..., repo: ..., dashboard: ...] |
| Created Date | [YYYY-MM-DD] |
| Last Reviewed | [YYYY-MM-DD] |


