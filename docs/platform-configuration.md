# 2. Nobl9 Platform Configuration

A well-structured Nobl9 deployment begins with thoughtful configuration of the platform's organizational primitives: projects, services, labels, and annotations. Getting this right early prevents costly restructuring as your SLO practice scales.

> :material-book-open-variant: **Docs:** [Nobl9 Getting Started Guide](https://docs.nobl9.com/getting-started/)

**GUI and Code-First Configuration**

Nobl9 resources—projects, services, SLOs, alert policies, and data sources—can be configured through the Nobl9 web UI or declaratively through YAML (applied via sloctl) and Terraform. Most organizations adopt a code-first approach for production resources, using the GUI primarily for exploration and ad-hoc analysis. Regardless of which method you use, all resources follow the same naming and uniqueness rules described below.

**Resource Names vs. Display Names**

Every Nobl9 resource has two identifiers. The `name` field is a Kubernetes-style resource identifier: it must be lowercase, alphanumeric, and may include dashes (no spaces or special characters). This is the immutable identifier used in YAML definitions, Terraform configurations, API calls, and sloctl commands. The `displayName` field is a human-friendly label that appears in the Nobl9 UI. Display names accept free-form text including spaces, proper casing, and special characters (e.g., `Payments API – v2`).

**Uniqueness Rules**

Project names must be unique across the entire Nobl9 organization. Service and SLO names, however, only need to be unique within their parent project. This means two different projects can each contain a service named payments-api without conflict. Keep this scoping in mind when designing your project structure—it gives teams autonomy over their own naming while preventing project-level collisions.


| Resource | Name Scope | Name Format | Display Name |
| --- | --- | --- | --- |
| Project | Unique across the organization | Lowercase, alphanumeric, dashes | Free-form text |
| Service | Unique within its project | Lowercase, alphanumeric, dashes | Free-form text |
| SLO | Unique within its project | Lowercase, alphanumeric, dashes | Free-form text |
| Alert Policy | Unique within its project | Lowercase, alphanumeric, dashes | Free-form text |

> :material-book-open-variant: **Docs:** [Nobl9 Resource Naming](https://docs.nobl9.com/getting-started/nobl9-resources/)


## 2.1 Projects: Organizational Boundaries

Projects are the primary logical grouping of resources in Nobl9. They serve as both an organizational boundary and a security boundary through RBAC. Every service, SLO, alert policy, and data source connection exists within a project.

> :material-book-open-variant: **Docs:** [Projects in Nobl9](https://docs.nobl9.com/getting-started/nobl9-resources/project/)


### 2.1.1 Project Design Patterns

There are three common patterns for organizing projects. Choose the one that best matches your organizational structure:


| Pattern | Description | Best For |
| --- | --- | --- |
| Team-Based | One project per team (e.g., payments-team, search-team). Each team owns and manages all resources within their project. | Organizations where teams have clear ownership boundaries and limited cross-team dependencies. |
| Domain-Based | One project per business domain (e.g., checkout, catalog, user-auth). Multiple teams may contribute services within a domain. | Organizations aligned around business capabilities or product areas. |
| Environment-Based | Separate projects for each environment (e.g., payments-prod, payments-staging). The same services exist across multiple projects. | Organizations that need different SLO targets or alerting policies per environment. |

**Recommendation:**

For most large organizations, a team-based or domain-based pattern works best. Avoid creating too many projects (more than 50) as this increases administrative overhead. Use labels for cross-cutting concerns like environment or region rather than duplicating project structures.


### 2.1.2 Project Naming Conventions

As described above, project names must be unique across the entire organization, so choose names that are specific enough to avoid collisions. Establish a naming convention early and document it. Common patterns include `[domain]-[team]` (e.g., `checkout-backend`), `[team]-[scope]` (e.g., `platform-infra`), or `[product]-[area]` (e.g., `mobile-api`). Choose a convention that is idiomatic to your existing naming patterns for repositories, services, and infrastructure.


## 2.2 Services: What You Measure

A service in Nobl9 represents anything you want to set an SLO for. It can map to a microservice, an API endpoint, a database, a user journey, or any logical grouping of reliability concerns. Every SLO must be tied to a service, and every service lives within a project.

> :material-book-open-variant: **Docs:** [Services in Nobl9](https://docs.nobl9.com/getting-started/nobl9-resources/service/)


### 2.2.1 Service Design Principles

1. Map to real user-facing capabilities. A service should represent something a user or dependent system interacts with, not an internal implementation detail.
2. Keep services at the right granularity. Too coarse and you lose actionable signal; too fine and you drown in SLOs. A good rule of thumb: if a team would respond to an outage of this service as a single incident, it should be a single service.


### 2.2.2 Service YAML Example

The following YAML defines a service with labels and annotations:


```yaml
apiVersion: n9/v1alpha
kind: Service
metadata:
  name: payments-api
  displayName: Payments API
  project: checkout-team
  labels:
    team: checkout
    tier: critical
    env: production
    layer: application        # tiering label
  annotations:
    owner: checkout-backend@company.com
    runbook: https://wiki.internal/runbooks/payments-api
    oncall: https://oncall.internal/schedules/checkout
    repo: https://github.com/org/payments-api
    architecture-doc: https://wiki.internal/arch/payments-api
```


## 2.3 Labels: Organizing Across Boundaries

Labels are key-value pairs attached to projects, services, SLOs, and alert policies. They enable filtering, grouping, and reporting across organizational boundaries. Unlike projects (which are hard boundaries), labels create flexible, cross-cutting views of your reliability data.

> :material-book-open-variant: **Docs:** [Labels in Nobl9](https://docs.nobl9.com/features/labels/)


### 2.3.1 Recommended Label Taxonomy

Establish a standard set of label keys that all teams use consistently. The following taxonomy covers the most common organizational needs. Note the inclusion of the `layer` label, which is central to the tiering strategy described in Section 3:


| Label Key | Purpose | Example Values |
| --- | --- | --- |
| team | Identifies the owning team | checkout, search, platform, mobile |
| tier | Criticality classification for prioritization | critical, high, medium, low |
| layer | Architectural layer for tiering strategy (see Section 3) | user-journey, application, platform, infrastructure, dependency |
| env | Deployment environment | production, staging, development |
| region | Geographic region or data center | us-east, eu-west, ap-south |
| customer-type | Customer segment (for segment-specific SLOs) | enterprise, trial, free |
| domain | Business domain or product area | payments, catalog, auth, shipping |
| compliance | Regulatory or compliance requirements | pci, hipaa, sox, gdpr |
| data-source | Underlying monitoring system | datadog, prometheus, cloudwatch |


### 2.3.2 Enforcing Label Requirements with CI/CD Linting

Inconsistent labeling is one of the most common pitfalls in SLO programs at scale. Without enforcement, teams create ad-hoc labels that break cross-team reporting and dashboards. Enforce your label taxonomy programmatically by adding a linting step to your CI/CD pipeline.

**Recommended Toolchain for Label Enforcement:**


| Tool | Role | How It Helps |
| --- | --- | --- |
| sloctl apply --dry-run | Syntax and schema validation | Validates that all YAML is well-formed and conforms to the Nobl9 API schema before any changes are applied. |
| Custom YAML linter (yq + shell script) | Label policy enforcement | A shell script that uses yq to parse YAML and verify required labels are present with allowed values. See example below. |
| OPA / Conftest | Advanced policy-as-code | Open Policy Agent or Conftest can enforce complex label policies (e.g., if layer=application then tier is required). Ideal for organizations already using OPA for Kubernetes policies. |
| GitHub Actions / GitLab CI | Pipeline orchestration | Runs the validation steps automatically on every pull request, blocking merge if policies are violated. |
| Pre-commit hooks | Developer-local enforcement | Catches violations before code is pushed, giving developers immediate feedback without waiting for CI. |

**Example: Label Linting Script (lint-slo-labels.sh)**


```bash
#!/bin/bash
# Lint Nobl9 YAML files for required labels
REQUIRED_LABELS=("team" "tier" "layer" "env")
ALLOWED_TIERS=("critical" "high" "medium" "low")
ALLOWED_LAYERS=("user-journey" "application" "platform" "infrastructure" "dependency")

ERRORS=0
for file in "$@"; do
  for label in "${REQUIRED_LABELS[@]}"; do
    val=$(yq '.metadata.labels.'"$label" "$file" 2>/dev/null)
    if [ "$val" = "null" ] || [ -z "$val" ]; then
      echo "ERROR: $file missing required label: $label"
      ERRORS=$((ERRORS + 1))
    fi
  done
  # Validate tier values
  tier=$(yq '.metadata.labels.tier' "$file" 2>/dev/null)
  if [ "$tier" != "null" ] && [[ ! " ${ALLOWED_TIERS[*]} " =~ " $tier " ]]; then
    echo "ERROR: $file has invalid tier value: $tier"
    ERRORS=$((ERRORS + 1))
  fi
done
exit $ERRORS
```

**Example: Conftest Policy (policy/labels.rego)**


```rego
package main

required_labels := ["team", "tier", "layer", "env"]
allowed_tiers := ["critical", "high", "medium", "low"]
allowed_layers := ["user-journey", "application", "platform", "infrastructure", "dependency"]

deny[msg] {
  label := required_labels[_]
  not input.metadata.labels[label]
  msg := sprintf("Missing required label: %s", [label])
}

deny[msg] {
  input.metadata.labels.tier
  not input.metadata.labels.tier in allowed_tiers
  msg := sprintf("Invalid tier: %s. Allowed: %v",
    [input.metadata.labels.tier, allowed_tiers])
}
```


### 2.3.3 Label Naming Rules

Label keys in Nobl9 must follow specific formatting rules. Keys can only contain lowercase alphanumeric characters, underscores, and dashes. They must start with a letter and end with an alphanumeric character. The maximum key length is `63` characters. Values can contain Unicode characters with a maximum length of `200` characters.

**Tip:**

Align your label keys with existing conventions in your monitoring and infrastructure tooling (Kubernetes labels, Datadog tags, etc.) to reduce the cognitive overhead of context switching.


## 2.4 Annotations: Contextual Links and Event Markers

Nobl9 supports two distinct types of annotations, each serving a different purpose. It is important to understand the difference because they are configured differently and serve different workflows.

> :material-book-open-variant: **Docs:** [SLO Annotations in Nobl9](https://docs.nobl9.com/features/slo-annotations/)


### 2.4.1 Metadata Annotations (Links on Nobl9 Objects)

Metadata annotations are key-value pairs attached to Nobl9 objects (services, SLOs, projects). In practice, these are links: URLs that point to related resources elsewhere in your toolchain. They appear in the metadata block of the SLO details page in the Nobl9 UI, providing one-click navigation to context that helps engineers respond to incidents or conduct reviews.

Unlike labels, metadata annotations are not used for filtering or grouping. They are purely contextual navigation aids. Common metadata annotations include:


| Annotation Key | What It Links To | Example Value |
| --- | --- | --- |
| owner | Team or individual contact | checkout-backend@company.com |
| runbook | Operational runbook for the service | https://wiki.internal/runbooks/payments-api |
| oncall | On-call schedule (e.g., PagerDuty) | https://oncall.internal/schedules/checkout |
| repo | Source code repository | https://github.com/org/payments-api |
| architecture-doc | Service architecture documentation | https://wiki.internal/arch/payments-api |
| dashboard | Primary monitoring dashboard | https://datadog.com/dash/payments-overview |
| slack-channel | Team's primary Slack channel | https://slack.com/archives/C0123CHECKOUT |

**Best Practice:**

Require at minimum the owner, runbook, and oncall annotations on every service. Enforce these requirements through your CI/CD linting pipeline alongside label requirements. When an on-call engineer receives an SLO alert at 3 AM, these links are the fastest path to context.


### 2.4.2 SLO Annotations (Event Markers on Timelines)

SLO annotations are time-bound event notes that appear directly on SLO charts. They provide visual context for reliability events. Nobl9 supports both manual and automated SLO annotations:

**System-Generated Annotations (Automatic):**

- SLO Edit Annotations: Nobl9 automatically creates an annotation every time an SLO is edited, showing what changed (via YAML diff), who made the change, the source (UI, sloctl, Terraform), and whether the change impacted the error budget.
- No-Data Anomaly Annotations: When a no-data anomaly is detected, Nobl9 creates an annotation marking the period.
- Alert Annotations: When an alert policy triggers, Nobl9 annotates the SLO timeline.
**Recommended Automated Annotations (Configure in CI/CD):**

The Nobl9 API makes it straightforward to create annotations programmatically. We strongly recommend automating the following annotations in your deployment pipeline:


| Annotation Type | When to Create | What to Include | How to Automate |
| --- | --- | --- | --- |
| Deployment Marker | Every production deployment | Service version, commit SHA, deployer, link to release notes | Add a POST to the Nobl9 Annotations API as a post-deploy step in your CI/CD pipeline. |
| Rollback Marker | Every production rollback | Rolled-back-from version, rolled-back-to version, reason | Trigger from your rollback automation or runbook. |
| Incident Start/End | When an incident is declared and resolved | Incident ID, severity, link to incident channel or postmortem | Integrate with PagerDuty or your incident management tool via webhook. |
| Maintenance Window | Before and after planned maintenance | Maintenance type, expected duration, affected components | Create from your change management system or maintenance scheduler. |
| Configuration Change | When infrastructure or config changes are applied | Change description, Terraform plan link, approver | Add as a post-apply hook in Terraform or your config management tool. |

**Example: Deployment Annotation via sloctl**


```yaml
# Add to your CI/CD post-deploy step
cat <<EOF | sloctl apply -f -
apiVersion: n9/v1alpha
kind: Annotation
metadata:
  name: deploy-${BUILD_NUMBER}
  project: checkout-team
spec:
  slo: payments-api-availability
  description: "Deployed v${VERSION} (${COMMIT_SHA})"
  startTime: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  endTime: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EOF
```


## 2.5 Data Source Configuration

Nobl9 connects to your existing monitoring and observability tools to collect SLI metrics. The platform supports over 25 data sources including Datadog, Prometheus, Amazon CloudWatch, Splunk, New Relic, Dynatrace, Elasticsearch, Google Cloud Monitoring, and many more.

> :material-book-open-variant: **Docs:** [Nobl9 Data Sources](https://docs.nobl9.com/sources/)


### 2.5.1 Agent vs. Direct Connection

Nobl9 offers two connection methods for data sources. The Agent method deploys a lightweight agent in your infrastructure that pulls metrics and sends them to Nobl9. The Direct method connects Nobl9 directly to your monitoring tool's API. For most enterprise deployments, the Agent method is preferred as it keeps credentials within your network boundary and provides more control over data flow.


### 2.5.2 Handling No-Data Conditions

Missing data is one of the most insidious problems in SLO monitoring. If your data source stops sending metrics, you might not realize your SLO is unmonitored until an incident exposes the gap. Nobl9 provides built-in no-data anomaly detection that should be configured on every SLO.

> :material-book-open-variant: **Docs:** [Data Anomaly Detection](https://docs.nobl9.com/slo-oversight/data-anomalies/)

**No-Data Anomaly Alert Configuration:**

- Default threshold: Nobl9 sends a notification when an SLO reports no data for 15 minutes. You can customize this from 5 minutes to 31 days.
- Configure up to 5 alert methods per SLO for no-data notifications.
- When a no-data anomaly is detected, Nobl9 automatically creates an SLO annotation and sends a notification using your configured alert method.
- No-data anomaly detection is separate from regular alert policies. Alerts fire when alert policy conditions are met; no-data anomalies fire when data stops flowing entirely.
**Recommended No-Data Configuration by Tier:**


| Service Tier | No-Data Threshold | Alert Method | Rationale |
| --- | --- | --- | --- |
| Critical | 5 minutes | PagerDuty + Slack | Critical services must be monitored continuously. Any data gap should be investigated immediately. |
| High | 15 minutes (default) | Slack team channel | Brief gaps may be tolerable, but extended outages in monitoring are unacceptable. |
| Medium | 30 minutes | Slack team channel | Allows for transient data source issues without excessive noise. |
| Low | 1 hour | Weekly digest or email | Non-critical services can tolerate longer monitoring gaps. |

**Additional Data Anomaly Detection:**

Beyond no-data detection, Nobl9 SLO Oversight also detects constant-burn anomalies (where an SLO continuously consumes its error budget without recovery, suggesting a systemic issue) and no-burn anomalies (where an SLO shows perfect reliability for extended periods, suggesting the target may be too loose to provide useful signal). Configure alerts for both to maintain SLO hygiene.


### 2.5.3 Data Source Best Practices

- Create one data source connection per monitoring tool per project. This keeps access scoped and manageable.
- Use service accounts with read-only permissions for data source credentials.
- Document which data source backs each SLO using the data-source label.
- Test data source connections thoroughly before creating SLOs. Nobl9 provides connection testing capabilities.
- For organizations using multiple monitoring tools, consider standardizing on one tool per service tier or domain to reduce query complexity.
- Configure no-data anomaly alerts on every SLO, using the tier-based thresholds above.
- After resolving a no-data issue, use Nobl9's SLO replay feature to backfill historical SLI data for the gap period.