# 9. Common Pitfalls and How to Avoid Them


| Pitfall | Why It Happens | How to Avoid It |
| --- | --- | --- |
| Setting 100% or near-100% targets | Teams aspire to perfect reliability without considering the cost. | Start with current baseline minus a small buffer. Educate teams that error budgets enable velocity. |
| Too many SLOs per service | Teams try to measure everything at once. | Start with 1-2 SLOs per service. Add more only when they provide new actionable signal. |
| SLOs without owners | SLOs are created during initial enthusiasm but nobody maintains them. | Require an owner annotation on every SLO. Use Nobl9 Oversight to track review compliance. |
| Alert fatigue | Alert thresholds too sensitive or too many alert methods configured. | Use multi-window burn rate alerting. Start conservative and tighten over time. |
| Inconsistent labeling | No taxonomy established, or teams create ad hoc labels. | Enforce labels with CI/CD linting. Define taxonomy before scaling beyond pilot. |
| Measuring infrastructure, not user experience | Teams measure CPU and memory instead of user-facing indicators. | Always start with user journeys. Use the tiering model to separate layers. |
| Ignoring error budget policies | Policies exist on paper but lack enforcement. | Secure executive sponsorship. Make budget status visible in standups and dashboards. |
| No-data blind spots | Teams do not configure no-data anomaly alerts. | Configure no-data alerts on every SLO using tier-based thresholds (Section 2.5.2). |
| Treating SLOs as set-and-forget | Teams create SLOs once and never review. | Use Nobl9 SLO Oversight review cycles. Overdue status creates accountability. |
| Flat SLO structure without tiering | All SLOs treated equally regardless of layer. | Implement the five-layer tiering model (Section 3). Use composite SLOs for cross-layer views. |
