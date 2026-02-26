# 5. Ownership, Governance, and Review Cycles

![](images/ownership-governance-illustration.png)

Clear ownership and structured governance are the single most important factors in a successful SLO program. Without them, SLOs become stale metrics that nobody acts on. This section defines roles, responsibilities, governance structures, and the Nobl9 SLO Oversight features that enforce them.


## 5.1 Roles and Responsibilities


| Role | Responsibilities | Typical Person |
| --- | --- | --- |
| SLO Process Owner | Owns the overall SLO program. Sets organizational standards, defines review cadence, drives adoption, and reports program health to leadership. | Head of SRE, VP of Engineering, or Platform Engineering lead. |
| SLO Champion (per team) | Drives SLO adoption within their team. Maintains SLO definitions, leads team reviews, represents the team in cross-team forums. | Senior engineer or tech lead within each team. |
| Service Owner | Responsible for the reliability of their service. Maintains SLI definitions, responds to error budget alerts, and makes prioritization decisions. | Engineering manager or senior engineer who owns the service. |
| Platform Admin | Manages the Nobl9 platform configuration, including projects, data sources, RBAC, and integrations. | SRE or platform engineering team member. |
| Executive Sponsor | Provides organizational authority and resources. Resolves cross-team conflicts and prioritization disputes. | VP of Engineering, CTO, or equivalent. |


## 5.2 RBAC Configuration

Nobl9 provides granular Role-Based Access Control at both the organization and project levels, inspired by the Google Cloud permission model.

> :material-book-open-variant: **Docs:** [RBAC Overview](https://docs.nobl9.com/access-management/rbac/)

> :material-book-open-variant: **Docs:** [Project-Level Roles](https://docs.nobl9.com/access-management/rbac/project-roles/)


### 5.2.1 Organization-Level Roles


| Role | Access | Assign To |
| --- | --- | --- |
| Organization Admin | Full read/write access to all resources. Can manage users, SSO, and platform settings. | Platform Admins, SLO Process Owner. |
| Organization Viewer | Read-only access to all resources. Can view SLOs in the Service Health Dashboard and Grid view. | Executives, product managers, stakeholders needing visibility. |
| Organization Responder | Read-only access plus ability to create SLO Annotations and silence alerts. | On-call engineers, incident responders. |


### 5.2.2 Project-Level Roles


| Role | Access | Assign To |
| --- | --- | --- |
| Project Owner | Full control within the project. Can manage users, services, SLOs, and integrations. | Team lead or SLO Champion for that team. |
| Project Editor | Can create and modify services, SLOs, and alert policies within the project. | Engineers actively maintaining SLOs. |
| Project Viewer | Read-only access to the project's resources. | Team members needing visibility. |
| Integrations User | Can manage data source connections within the project. | Engineers setting up monitoring integrations. |

**Best Practice:**

Follow the principle of least privilege. Most team members should start as Project Viewers and be elevated to Editor as they begin actively maintaining SLOs. Reserve Project Owner and Organization Admin roles for designated individuals.


## 5.3 Security Best Practices

Securing your Nobl9 deployment involves three pillars: authenticating users through SSO and identity management, managing programmatic credentials (API keys and access keys), and securing the connections between Nobl9 and your data sources. This section provides best practices for each.


### 5.3.1 SSO and Identity Management

Nobl9 supports Single Sign-On through Okta, Azure AD, and Google identity providers. SSO is an Enterprise feature and must be configured by an Organization Admin. Once enabled, all users authenticate through your corporate identity provider rather than maintaining separate Nobl9 credentials.

> :material-book-open-variant: **Docs:** [RBAC Groups (SCIM)](https://docs.nobl9.com/access-management/rbac/rbac-groups/)

> :material-book-open-variant: **Docs:** [Access Management](https://docs.nobl9.com/access-management/)

For organizations using Azure AD or Okta, Nobl9 supports SCIM synchronization to automatically import user groups from your identity provider. Once synchronized, Organization Admins can assign role bindings to imported groups directly from the Nobl9 UI or via sloctl, eliminating the need to manage individual user permissions.

**Best Practices:**

- Enforce SSO for all user logins. This centralizes authentication and ensures offboarded employees lose access automatically.
- Set the default role for new SSO logins to Organization Viewer. Users can then be elevated to more permissive roles as needed, following the principle of least privilege.
- Use SCIM group synchronization to map your existing team structure to Nobl9 project roles. This reduces manual role management overhead as teams grow.

### 5.3.2 API Keys and User Access Keys

Nobl9 provides two types of programmatic credentials for authenticating with the API and sloctl:


| Credential Type | Scope | Managed By | Use Case |
| --- | --- | --- | --- |
| Organization API Keys | Organization-wide, not tied to a user identity. | Organization Admins (Settings > API keys). | CI/CD pipelines, Terraform automation, shared service accounts. |
| User Access Keys | Tied to an individual user. Max 2 keys per user. | Each user (Settings > My user access keys). | Individual sloctl usage, personal scripting, local development. |

For both credential types, the client secret is displayed only once at creation. If lost, the key must be regenerated. Suspended users have their access keys automatically deactivated.

> :material-book-open-variant: **Docs:** [API Keys](https://docs.nobl9.com/access-management/api-keys/)

> :material-book-open-variant: **Docs:** [User Access Keys](https://docs.nobl9.com/access-management/access-keys/)

**Best Practices:**

- Request an automatic expiration policy from Nobl9 to enforce regular key rotation across your organization. This applies to all newly created keys.
- Use Organization API keys for CI/CD pipelines and shared automation. Use User Access Keys for individual sloctl usage so actions are attributable to specific engineers.
- Store client IDs and secrets in a secrets manager (HashiCorp Vault, AWS Secrets Manager, or your CI/CD platform's secret store). Never commit credentials to version control or store them in `.env` files checked into repositories.
- Audit active API keys and user access keys quarterly. Deactivate or delete keys that are no longer in use.

### 5.3.3 Securing Data Source Connections

Nobl9 offers two methods for connecting to data sources, each with different security trade-offs:


| Property | Agent Connection | Direct Connection |
| --- | --- | --- |
| Credentials stored in Nobl9 | No. Credentials remain in your environment. | Yes. Encrypted and stored in Nobl9. |
| Requires deployment | Yes. Runs as a container in Kubernetes or Docker. | No. Nobl9 connects directly to your data source. |
| Exposes your data source | No. Agent makes outbound connections only. | Yes. Requires an open port for inbound Nobl9 traffic. |
| Setup complexity | Higher. Requires K8s/Docker deployment and credential injection. | Lower. Configure credentials in the Nobl9 UI. |
| Best for | Production environments with strict security requirements. | Non-production environments or sources with existing public APIs. |

> :material-book-open-variant: **Docs:** [Nobl9 Agent](https://docs.nobl9.com/nobl9-agent/)

> :material-book-open-variant: **Docs:** [Agent vs. Direct Connection](https://docs.nobl9.com/slocademy/Agent/direct-vs-agent/)

**Best Practices:**

- Prefer agent connections for production data sources. Credentials never leave your infrastructure, and no inbound ports need to be opened.
- Pass agent credentials via mounted Kubernetes secrets or a secrets manager rather than inline environment variables. This prevents secrets from appearing in `kubectl describe` output or container inspection.
- Use read-only service accounts for data source credentials. Nobl9 only needs to query metrics; it should never have write access to your monitoring systems.

### 5.3.4 Credential Hygiene Checklist

Use this checklist during initial deployment and revisit it quarterly as part of your security review:

- [ ] Enforce SSO for all user logins; disable password-based authentication
- [ ] Set default SSO role to Organization Viewer (least privilege)
- [ ] Enable automatic key expiration policy for API keys and user access keys
- [ ] Rotate all API keys on a defined schedule (e.g., every 90 days)
- [ ] Use agent connections for all production data sources
- [ ] Store agent credentials in a secrets manager (Vault, AWS Secrets Manager, etc.)
- [ ] Verify no client IDs or secrets are committed to version control
- [ ] Use read-only service accounts for all data source credentials
- [ ] Restrict Organization Admin role to designated platform administrators only
- [ ] Audit active API keys and user access keys; deactivate unused keys
- [ ] Review SCIM group mappings to ensure role bindings reflect current team structure

## 5.4 Nobl9 SLO Oversight and Review Cycles

Nobl9 SLO Oversight is an enterprise feature that transforms SLOs from static snapshots into a living, governed system. It ensures that every SLO has an owner, a review cycle, and a clear definition. Oversight creates a clear record of how SLOs are maintained, reviewed, and acted on.

> :material-book-open-variant: **Docs:** [SLO Oversight](https://docs.nobl9.com/slo-oversight/)

> :material-book-open-variant: **Docs:** [SLO Reviews (Enterprise)](https://docs.nobl9.com/slo-oversight/reviews/)

> :material-book-open-variant: **Docs:** [SLO Oversight Dashboard](https://docs.nobl9.com/dashboards/slo-oversight-dashboard/)


### 5.4.1 Why SLO Reviews Matter

SLOs rarely fail all at once. They decay slowly, quietly drifting out of sync with how your systems work and what your customers expect. Definitions go stale. Ownership fades. Metrics keep reporting green while reality shifts around them. Regular reviews catch this drift before it causes real damage.


### 5.4.2 Configuring Review Schedules in Nobl9

To schedule a review in Nobl9, open the service wizard, select Schedule review, and configure the schedule start, time zone, and repeat options. Review frequency can be customized using the iCalendar format (RRULE) for advanced scheduling. Nobl9 manages review statuses automatically through a five-state lifecycle:


| Status | Meaning | Transition |
| --- | --- | --- |
| Not Started | Review has not been scheduled for this SLO. | Becomes To Review when the first review due date arrives. |
| To Review | SLO is due for review. Action required. | Changes to Reviewed when completed, or Skipped if deferred. Becomes Overdue if not reviewed by the deadline. |
| Reviewed | SLO has been reviewed in the current cycle. | Automatically returns to To Review at the start of the next cycle. |
| Skipped | Review was intentionally deferred for this cycle. | Automatically returns to To Review at the start of the next cycle. |
| Overdue | SLO was not reviewed before the deadline. | Remains Overdue until explicitly reviewed. Affects SLO quality score. Does not reset with new cycle. |


### 5.4.3 Recommended Review Cadence

We recommend a tiered review cadence that matches the strategic importance of each review level:


| Review Type | Frequency | Participants | Focus Areas | Nobl9 Feature |
| --- | --- | --- | --- | --- |
| Operational Review | Weekly | Service team, SLO champion | Current error budget status, recent incidents, no-data anomalies, any immediate adjustments. | Service Health Dashboard, Alert Center |
| SLO Target Review | Monthly | Service team, SRE, product manager | Are targets appropriate? Are SLIs measuring the right things? Review SLO Oversight statuses. Address any Overdue reviews. | SLO Oversight review workflow, SLO detail pages |
| Governance Review | Monthly | SLO Process Owner, Platform Admin | Label compliance audit, RBAC review, onboarding status, CI/CD pipeline health, data anomaly trends. | SLO Oversight quality scores, label-based filtering |
| Strategic Review | Quarterly | Engineering leadership, product, SRE | Program health, cross-team trends, investment priorities, maturity assessment, composite SLO performance. | Cross-service reports, composite SLO dashboards |


### 5.4.4 What to Review in Each Cycle

**During an SLO review, evaluate the following:**

1. Was the SLO met? This is the most fundamental check. Was the service reliable enough?
2. Error budget consumption pattern: High consumption may indicate a single major incident or accumulation of minor issues. Analyze the trend to determine where to focus engineering efforts.
3. Low or no consumption: If you are consistently consuming very little error budget, the SLO may be too loose. An overly loose SLO fails to provide useful signal. Consider tightening the target.
4. Data quality: Are no-data anomalies occurring? Is the constant-burn or no-burn anomaly detector flagging issues? These indicate potential SLO configuration problems.
5. Ownership currency: Is the owner annotation still accurate? Has the team or on-call schedule changed?
6. SLI relevance: Do the SLIs still reflect the user experience? Has the service changed in ways that make current SLIs less relevant?
7. Target appropriateness: Based on business changes, traffic patterns, or architectural changes, does the target need adjustment?


### 5.4.5 Integrating Reviews into Daily Work

SLO Oversight is designed to connect with daily workflows, not create parallel processes. Practical integration points include:

- Slack: Configure Nobl9 to post review reminders and Overdue notifications to team Slack channels.
- Standups: Include error budget status as a standing item in daily standups. Teams should know their budget health as naturally as they know their sprint velocity.
- Retrospectives: Include SLO performance data in sprint retrospectives and postmortems.
- Dashboards: Add SLO Oversight status widgets to team dashboards so review status is always visible.

## 5.5 Governance Workflows


### 5.5.1 SLO Change Management

When using SLOs-as-code, all changes to SLO definitions should go through your standard code review process. This ensures that target changes are reviewed by at least one other team member, SLI query changes are validated against the data source, alert policy changes are reviewed for appropriate escalation, and a clear audit trail exists for all SLO modifications. Nobl9's automatic SLO edit annotations provide an additional audit trail showing what changed, who changed it, and whether the change impacted the error budget.

> :material-book-open-variant: **Docs:** [SLO Management (Moving & Editing SLOs)](https://docs.nobl9.com/service-level-objectives/slo-management/)


### 5.5.2 Escalation Paths

Define clear escalation paths for error budget violations:

1. The service owner is notified and conducts an initial assessment.
2. The SLO Champion coordinates a team review of the top error contributors.
3. If the budget remains exhausted after one week, the engineering manager is engaged.
4. If cross-team dependencies are involved, the SLO Process Owner facilitates a cross-team review.
5. If the budget remains exhausted for a full cycle, the Executive Sponsor is briefed for prioritization decisions.


### 5.5.3 Error Budget Policies


| Budget Status | Required Actions |
| --- | --- |
| Healthy (more than 50% remaining) | Normal development velocity. Teams deploy freely and take on calculated risks. |
| Caution (25% to 50% remaining) | Increased deployment scrutiny. Review recent changes for reliability impact. Ensure rollback plans. |
| Warning (10% to 25% remaining) | Slow deployment cadence. Prioritize reliability fixes. Review top error contributors. |
| Exhausted (less than 10% remaining) | Freeze non-critical deployments. Focus exclusively on reliability. Formal review with engineering leadership. |

**Important:**

The error budget policy should not be punitive. Its purpose is to give teams permission to focus on reliability when data shows reliability is the priority. Frame it as a tool that protects the team, not one that penalizes them.
