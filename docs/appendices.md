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
| Layer | [Application / Platform / Infrastructure / Dependency] |
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


## 10.2 Appendix B: SLODLC Phase Checklist

**Phase 0: Initiate**

- [ ] Executive sponsor identified and briefed
- [ ] Pilot teams selected
- [ ] SLO Champions appointed
- [ ] Success criteria defined
- [ ] Timeline and milestones established
**Phase 1: Discover**

- [ ] User journeys mapped (AI-assisted or manual)
- [ ] SLI candidates identified for each journey
- [ ] Services classified into tiering model (application, platform, infrastructure, dependency)
- [ ] Data source readiness assessed
- [ ] Instrumentation gaps documented
**Phase 2: Design**

- [ ] Budgeting method selected for each SLO
- [ ] Initial targets set based on baseline data and tiering model
- [ ] Time windows configured
- [ ] SLO specifications documented using the template
- [ ] Error budget policies drafted
**Phase 3: Implement**

- [ ] Nobl9 projects and services created with required labels
- [ ] Data sources configured and tested
- [ ] SLOs created via sloctl or Terraform (code-first approach)
- [ ] Alert policies configured using multi-window burn rate presets
- [ ] No-data anomaly alerts configured based on tier
- [ ] Alert methods connected and tested (Slack, PagerDuty, ServiceNow)
- [ ] RBAC roles assigned
- [ ] CI/CD pipeline configured with label linting and dry-run validation
**Phase 4: Operate**

- [ ] Weekly review cadence established
- [ ] Monthly review cadence established
- [ ] Quarterly review cadence established
- [ ] Nobl9 SLO Oversight review schedules configured
- [ ] Error budget policies activated
- [ ] Composite SLOs configured for key user journeys
- [ ] Onboarding playbook for next teams prepared

## 10.3 Appendix C: Key References

All links below are clickable and will open in your browser.

**Nobl9 Core Documentation**

- Nobl9 Documentation Home: [docs.nobl9.com](https://docs.nobl9.com/)
- Getting Started Guide: [Getting Started](https://docs.nobl9.com/getting-started/)
- YAML Guide: [YAML Reference](https://docs.nobl9.com/yaml-guide/)
- SLO Management: [SLO Management](https://docs.nobl9.com/service-level-objectives/slo-management/)
- SLO Details Page: [SLO Details](https://docs.nobl9.com/service-level-objectives/details/)
**Platform Configuration**

- Projects: [Projects](https://docs.nobl9.com/getting-started/nobl9-resources/project/)
- Services: [Services](https://docs.nobl9.com/getting-started/nobl9-resources/service/)
- Labels: [Labels](https://docs.nobl9.com/features/labels/)
- SLO Annotations: [SLO Annotations](https://docs.nobl9.com/features/slo-annotations/)
- Data Sources: [Data Sources](https://docs.nobl9.com/sources/)
**Alerting**

- Alerting Overview: [Alerting](https://docs.nobl9.com/alerting/)
- Alert Policies: [Alert Policies](https://docs.nobl9.com/alerting/alert-policies/)
- Alert Presets: [Alert Presets](https://docs.nobl9.com/alerting/alert-presets/)
- Alert Methods: [Alert Methods](https://docs.nobl9.com/alerting/alert-methods/)
- Burn Rate Calculations: [Burn Rate](https://docs.nobl9.com/alerting/alerting-conditions/burn-rate/)
- Fast and Slow Burn: [Fast and Slow Burn](https://docs.nobl9.com/alerting/alerting-use-cases/fast-and-slow-burn/)
- ServiceNow Alert Method: [ServiceNow](https://docs.nobl9.com/alerting/alert-methods/servicenow/)
- PagerDuty Alert Method: [PagerDuty](https://docs.nobl9.com/alerting/alert-methods/pagerduty/)
**SLO Oversight & Governance**

- SLO Oversight: [SLO Oversight](https://docs.nobl9.com/slo-oversight/)
- SLO Reviews (Enterprise): [SLO Reviews](https://docs.nobl9.com/slo-oversight/reviews/)
- SLO Reviews with sloctl: [sloctl Reviews](https://docs.nobl9.com/slo-oversight/sloctl-review/)
- Data Anomaly Detection: [Data Anomalies](https://docs.nobl9.com/slo-oversight/data-anomalies/)
- Data Anomaly Troubleshooting: [Troubleshooting](https://docs.nobl9.com/guides/troubleshooting/data-anomaly/)
- SLO Oversight Dashboard: [Oversight Dashboard](https://docs.nobl9.com/dashboards/slo-oversight-dashboard/)
**RBAC & Access Management**

- RBAC Overview: [RBAC](https://docs.nobl9.com/access-management/rbac/)
- Project-Level Roles: [Project Roles](https://docs.nobl9.com/access-management/rbac/project-roles/)
**Composite SLOs**

- Composite SLO Essentials: [Essentials](https://docs.nobl9.com/composites/essentials/)
- Composite SLOs Guide: [Composite Guide](https://docs.nobl9.com/guides/slo-guides/composite-guide/)
- Reliability Roll-up Report: [Roll-up Report](https://docs.nobl9.com/reports/reliability-rollup/)
**SLOs as Code & CI/CD**

- SLOs as Code: [SLOs as Code](https://docs.nobl9.com/SLOs_as_code/)
- Terraform Provider: [Terraform Provider](https://docs.nobl9.com/slos-as-code/terraform-provider/)
- Terraform Registry: [nobl9/nobl9 Provider](https://registry.terraform.io/providers/nobl9/nobl9/latest/docs)
- GitHub Actions: [GitHub Actions](https://docs.nobl9.com/slos-as-code/ci-cd/github-actions/)
- sloctl CLI: [sloctl on GitHub](https://github.com/nobl9/sloctl)
- Nobl9 GitHub Action: [nobl9-action](https://github.com/nobl9/nobl9-action)
- sloctl Replay: [Replay](https://docs.nobl9.com/replay/replay-sloctl/)
**SLO Budgeting Methods**

- SLO Configuration: [SLOs](https://docs.nobl9.com/getting-started/nobl9-resources/slo/)
- Time Slices Guide: [Time Slices](https://docs.nobl9.com/guides/slo-guides/time-slices/)
- SLO Configuration Use Case: [Use Case](https://docs.nobl9.com/getting-started/use-case-slo-configuration/)
**External References**

- SLODLC Handbook: [slodlc.com](https://www.slodlc.com/slodlc_handbook/handbook/)
- Google SRE Book (Embracing Risk): [sre.google](https://sre.google/sre-book/embracing-risk/)
- Google SRE Workbook (Implementing SLOs): [sre.google](https://sre.google/workbook/implementing-slos/)
- Google SRE Workbook (Alerting on SLOs): [sre.google](https://sre.google/workbook/alerting-on-slos/)
- Google SRE Workbook (Error Budget Policy): [sre.google](https://sre.google/workbook/error-budget-policy/)
- Nobl9 SLO Best Practices: [nobl9.com](https://www.nobl9.com/service-level-objectives/slo-best-practices)
- Nobl9 Tips and Tricks: [nobl9.com/learn/tips](https://www.nobl9.com/learn/tips)