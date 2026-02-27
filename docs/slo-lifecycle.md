# 4. SLO Lifecycle Management (SLODLC)

![](images/slo-lifecycle-illustration.png)

The Service Level Objective Development Lifecycle (SLODLC) is an open-source framework that provides a structured, repeatable process for creating and managing SLOs. It consists of five phases: Initiate, Discover, Design, Implement, and Operate. This section maps each SLODLC phase to specific Nobl9 capabilities and organizational practices.

> :material-book-open-variant: **Docs:** [SLODLC Handbook](https://www.slodlc.com/slodlc_handbook/handbook/)

> :material-book-open-variant: **Docs:** [Nobl9 SLO Best Practices](https://www.nobl9.com/service-level-objectives/slo-best-practices)


## 4.1 Phase 0: Initiate

The Initiate phase establishes the organizational foundation for SLO adoption. Before defining a single SLO, you need executive sponsorship, a clear understanding of why SLOs matter to your organization, and a plan for scaling the practice.


### 4.1.1 Secure Executive Sponsorship

SLO adoption requires sustained investment in tooling, process change, and cultural shift. Without executive sponsorship, the initiative risks being deprioritized when competing with feature delivery. Present the business case in terms of outcomes: reduced downtime costs, faster incident response, improved cross-team alignment, and data-driven prioritization of reliability investments.


### 4.1.2 Identify Pilot Teams

Start with one or two teams that are already reliability-minded and have well-instrumented services. Ideal pilot teams have existing monitoring in a Nobl9-supported data source, a track record of incident response, clear service ownership, and willingness to experiment with new processes.


### 4.1.3 Establish Maturity Expectations

Set realistic expectations for the maturity journey:


| Stage | Duration | Characteristics |
| --- | --- | --- |
| Foundation | Months 1-3 | Pilot teams define first SLOs. Platform configuration established. Basic alerting configured. AI-assisted discovery for initial services. |
| Adoption | Months 3-6 | Additional teams onboard. Label taxonomy refined. Error budget policies drafted. SLOs-as-code introduced. |
| Standardization | Months 6-12 | CI/CD pipelines with label linting enforced. Review cycles established. Cross-team reporting via composite SLOs begins. |
| Optimization | 12+ months | Full tiering model deployed. SLO Oversight governance active. Error budget policies drive prioritization. SLOs inform capacity planning. |


## 4.2 Phase 1: Discover

The Discover phase maps user journeys and identifies the critical service interactions that SLOs should protect. The goal is to ensure that your SLOs measure what actually matters to users, not just what is easy to measure.


### 4.2.1 Using AI to Accelerate Discovery

Modern coding agents such as Claude Code, Cursor, and similar tools can dramatically accelerate the discovery phase. Rather than manually mapping every user journey and identifying SLI candidates, you can use AI agents to analyze your codebase, infrastructure configuration, and existing monitoring to generate initial SLO recommendations.

**Example Prompts for AI-Assisted Discovery:**

*Prompt 1: User Journey Mapping from Code*


```
Analyze the codebase in this repository and map the key user journeys
for our checkout service. For each journey, identify:
- The entry point (API endpoint or UI action)
- The sequence of backend service calls
- External dependencies (payment processors, email services, etc)
- Expected latency thresholds based on timeout configurations
- Error handling paths and failure modes
Output as a table mapping each journey to its critical path services.
```

*Prompt 2: SLI Candidate Identification from Monitoring Config*


```
Review the Datadog monitor definitions and Prometheus recording rules
in our monitoring/ directory. For each service with existing metrics:
- Identify availability SLI candidates (success rate metrics)
- Identify latency SLI candidates (histogram metrics with thresholds)
- Map each metric to the Nobl9 SLI query format
- Flag any gaps where services lack appropriate metrics
- Suggest the Nobl9 budgeting method (occurrences vs time-slices)
  based on the metric type
Output as a Nobl9 SLO YAML file ready for sloctl apply --dry-run.
```

*Prompt 3: Generate Initial SLO YAML from Architecture*


```
Read the architecture documentation in docs/architecture/ and the
Kubernetes manifests in k8s/. Generate a complete set of Nobl9 SLO
YAML definitions for the payments-api service, including:
- An availability SLO using the success rate from our Datadog metrics
- A latency SLO using the p99 latency from Prometheus
- Appropriate labels following our taxonomy: team, tier, layer, env
- Metadata annotations for runbook, oncall, and repo links
- Alert policies using multi-window burn rate (fast: 20x/5min,
  slow: 2x/6hr)
- No-data anomaly alert configured for 5-minute threshold
Set an initial availability target of 99.9% based on the SLA
documented in docs/slas/payments.md.
```

*Prompt 4: Dependency Analysis for Tiering*


```
Analyze the service dependency graph from our Kubernetes service mesh
configuration and Terraform infrastructure definitions. For each
service, classify it into our tiering model:
- User Journey layer: end-to-end workflows spanning multiple services
- Application / Service layer: user-facing services
- Platform layer: shared internal services
- Infrastructure layer: databases, caches, queues
- Dependency layer: external third-party services
Generate a tiering report with recommended SLO targets for each
layer, accounting for cascading failure patterns.
```

**Why Start with Code Instead of the UI:**

With coding agents now widely available, we recommend starting with SLOs-as-code from day one rather than beginning in the Nobl9 UI. The code-first approach provides several advantages: AI agents can generate initial YAML definitions from your existing codebase and monitoring configuration, all definitions are version-controlled from the start, code review processes catch mistakes before they reach production, and the transition from prototype to production is seamless since the same YAML files serve both purposes.

Use the Nobl9 UI as a visualization and validation tool rather than a creation tool. After applying your AI-generated SLO definitions with sloctl apply, use the Service Health Dashboard and SLO detail pages to verify that the queries return expected data and that targets are reasonable.


### 4.2.2 Manual Discovery Process

For services where AI-assisted discovery is not practical (e.g., legacy systems without infrastructure-as-code), follow the traditional SLODLC discovery process:

1. For each service in scope, identify the key user journeys it supports.
2. Document the user action that initiates each journey, the backend services involved, the expected latency, and the impact of failure.
3. Identify SLI candidates across the four standard categories: availability, latency, throughput, and quality/correctness.
4. Assess data source readiness: verify that metrics are available in your monitoring tools and that Nobl9 can query them.


### 4.2.3 SLI Category Reference


| SLI Category | Measures | Example |
| --- | --- | --- |
| Availability | Whether the service is responding to requests | Percentage of HTTP requests returning non-5xx responses |
| Latency | How fast the service responds | Percentage of requests completed within 200ms |
| Throughput | How much work the service can handle | Number of successful transactions per minute |
| Quality/Correctness | Whether the service returns correct results | Percentage of API responses with valid data |

Not every service needs all four SLI types. Start with availability and latency for most services, and add throughput or correctness SLIs only when they provide additional actionable signal.


## 4.3 Phase 2: Design

The Design phase translates discovered SLI candidates into concrete SLO specifications.

> :material-book-open-variant: **Docs:** [SLO Configuration in Nobl9](https://docs.nobl9.com/getting-started/nobl9-resources/slo/)

> :material-book-open-variant: **Docs:** [SLO Configuration Use Case](https://docs.nobl9.com/getting-started/use-case-slo-configuration/)


### 4.3.1 Choose a Budgeting Method


| Method | How It Works | Best For |
| --- | --- | --- |
| Occurrences | Counts good events against total events. Automatically adjusts for traffic volume. A 99.9% target means 99.9% of all requests must succeed. | Request-based services where each request is roughly equal. Most APIs and web services. |
| Time Slices | Divides the time window into one-minute slices and classifies each as good or bad. A 99.5% target means 99.5% of minutes must be good. | Services needing consistent performance regardless of traffic. Good for SLA compliance monitoring. |


### 4.3.2 Set Appropriate Targets

- Never set a 100% target. Every system fails eventually, and a 100% target creates zero error budget.
- Start with your current baseline. Measure actual reliability over the past 30 to 90 days and set your initial SLO slightly below that level.
- Align targets with your tiering model: infrastructure targets should be more stringent than application / service targets.
- Align with business requirements and any existing SLAs. Your SLO should be more stringent than your external SLA.
- Use the SLODLC Review phase to adjust targets iteratively. Your first SLO target will almost certainly need refinement.

### 4.3.3 Define Time Windows

- Rolling windows (e.g., 30-day rolling) provide a continuous view of reliability. Ideal for operational monitoring.
- Calendar-aligned windows (weekly, monthly, quarterly) align with business reporting cycles and Nobl9 review schedules.
For most organizations, use rolling windows for operational alerting and calendar-aligned windows for Nobl9 SLO Oversight review cycles.

> :material-book-open-variant: **Docs:** [Time Slices Budgeting Method](https://docs.nobl9.com/guides/slo-guides/time-slices/)


### 4.3.4 Threshold vs. Ratio Metrics

In Nobl9, SLIs can be defined using threshold metrics (a single time series evaluated against a threshold value) or ratio metrics (a count of good or bad events divided by total events). Ratio metrics are generally preferred because they naturally express the proportion of successful interactions.


## 4.4 Phase 3: Implement

The Implement phase deploys your designed SLOs into Nobl9 and configures the associated alerting.


### 4.4.1 Code-First Implementation

As discussed in Section 4.2.1, we recommend starting with SLOs-as-code from day one. Use AI-generated YAML as your starting point, validate with `sloctl apply --dry-run`, and iterate before applying to production. Use the Nobl9 UI for visualization and validation after applying definitions.


### 4.4.2 Use the SLI Analyzer

Nobl9 provides an SLI Analyzer that helps teams evaluate potential SLIs before committing to an SLO. Use it to validate that your metric query returns expected data, understand historical reliability against different thresholds, and identify the right target level based on actual performance.


### 4.4.3 Configure Alert Policies Using Nobl9 Templates

If you are unsure where to start with alert policies, Nobl9 offers alert presets (templates) for fast-burn and slow-burn policies. These presets follow SRE best practices for multi-window, multi-burn-rate alerting.

> :material-book-open-variant: **Docs:** [Alert Presets](https://docs.nobl9.com/alerting/alert-presets/)

> :material-book-open-variant: **Docs:** [Alert Policies](https://docs.nobl9.com/alerting/alert-policies/)

> :material-book-open-variant: **Docs:** [Burn Rate Calculations](https://docs.nobl9.com/alerting/alerting-conditions/burn-rate/)

> :material-book-open-variant: **Docs:** [Fast and Slow Burn Use Cases](https://docs.nobl9.com/alerting/alerting-use-cases/fast-and-slow-burn/)

> :material-book-open-variant: **Docs:** [Google SRE Workbook: Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/)

**Recommended Alert Policy Configuration:**

Multi-window, multi-burn-rate alerting is the gold standard from Google's SRE Workbook. The principle is to pair a short window with a long window for each severity level. A good guideline is to make the short window 1/12th the duration of the long window.


| Alert Severity | Short Window (Burn Rate) | Long Window (Burn Rate) | Notification | Expected Response |
| --- | --- | --- | --- | --- |
| Critical (Page) | 5 min at 20x burn | 1 hour at 5x burn | PagerDuty (high urgency) | Investigate immediately. Likely active incident. |
| Warning | 30 min at 5x burn | 6 hours at 2x burn | Slack team channel | Investigate within 1 hour. Check recent deployments. |
| Low / Slow Burn | 2 hours at 2x burn | 1 day at 1.5x burn | Slack + Jira ticket | Add to next standup. Review over next 24 hours. |
| Budget Threshold (25%) | N/A | N/A | Slack + email to manager | Conduct team review. Consider deployment freeze. |
| Budget Threshold (10%) | N/A | N/A | PagerDuty + Slack + ServiceNow | Escalate to leadership. Freeze non-critical deploys. |

**Example: Fast-Burn Alert Policy YAML (Using Nobl9 Presets)**

The following examples use PagerDuty and Slack as illustrative alert methods. Substitute the alert methods that match your organization's tooling.


```yaml
apiVersion: n9/v1alpha
kind: AlertPolicy
metadata:
  name: payments-api-fast-burn
  project: checkout-team
spec:
  description: Critical fast-burn alert for Payments API
  severity: High
  conditions:
    - measurement: averageBurnRate
      value: 20
      alertingWindow: 5m
      op: gte
  alertMethods:
    - metadata:
        name: pagerduty-checkout
        project: checkout-team
    - metadata:
        name: slack-slo-critical
        project: shared-alerts
```

**Example: Slow-Burn Alert Policy YAML**


```yaml
apiVersion: n9/v1alpha
kind: AlertPolicy
metadata:
  name: payments-api-slow-burn
  project: checkout-team
spec:
  description: Warning slow-burn alert for Payments API
  severity: Medium
  conditions:
    - measurement: averageBurnRate
      value: 2
      alertingWindow: 6h
      op: gte
  alertMethods:
    - metadata:
        name: slack-checkout-team
        project: checkout-team
```

**SRE Alerting Best Practices:**

- Precision over recall: it is better to miss a minor event than to page an engineer for a false alarm. Tune thresholds to reduce false positives.
- Every page must be actionable: if the on-call engineer cannot take meaningful action when paged, the alert should be a warning in Slack, not a PagerDuty incident.
- Evaluate alerting quality using four criteria: precision (every alert corresponds to a real event), recall (real events are not missed), detection time (how quickly alerts fire), and reset time (how quickly alerts clear after resolution).
- Apply multiple time windows to each SLO. Nobl9's own SRE team uses four alert policies per SLO: 15-minute, 1-hour, 6-hour, and 12-hour windows to distinguish between early indicators and severe incidents.
- Route by severity: fast burns to PagerDuty, slow burns to Slack, budget thresholds to Jira or ServiceNow.

## 4.5 Phase 4: Operate

The Operate phase covers ongoing SLO management, including review cycles, error budget management, and continuous improvement. This phase integrates directly with the Nobl9 SLO Oversight features described in Section 5.
