# 3. SLO Tiering Strategy

One of the most common questions when rolling out SLOs to a large organization is: how do we separate and relate SLOs across different layers of the stack? A payments API outage looks very different from a Kafka cluster performance degradation, even though both might affect the same user journey. A clear tiering strategy ensures that each team monitors the layer they own, error budgets are attributed to the right layer, composite SLOs aggregate upward to show end-to-end health, and executive dashboards reflect user-facing reliability while engineering dashboards show component-level detail.


## 3.1 The Five-Layer Model

We recommend organizing SLOs into five architectural layers. Use the `layer` label (defined in Section 2.3.1) to tag every service and SLO with its tier:


| Layer | What It Covers | Typical SLI Types | Who Owns It | Example Services |
| --- | --- | --- | --- | --- |
| User Journey | End-to-end workflows spanning multiple services | Composite availability, composite latency, task completion rate | Product / SRE leadership (cross-team) | Checkout Flow, Onboarding Funnel, Search-to-Purchase |
| Application / Service | User-facing services, APIs, and UIs that end users or API consumers interact with directly. | Availability, latency, correctness (from user's perspective) | Product engineering teams | Checkout API, Search UI, Mobile App Backend, Dashboard Web App |
| Platform | Shared internal services, middleware, and developer platforms that application teams depend on. | Availability, latency, throughput | Platform engineering / SRE teams | API Gateway, Service Mesh (Istio/Envoy), Auth Service, CI/CD Platform, Internal DNS |
| Infrastructure | Cloud resources, compute, storage, and networking that underpin everything. | Availability, throughput, capacity utilization | Infrastructure / Cloud engineering teams | Kubernetes Clusters, RDS/Aurora Databases, Redis Cache, CDN, Load Balancers |
| Dependency | Third-party services and external providers outside your direct control. | Availability, latency (measured from your side) | Vendor management / SRE teams (monitoring only) | Stripe API, Twilio SMS, Auth0, Salesforce API, AWS S3 |


## 3.2 Tiering Principles


### 3.2.1 User Journey SLOs Are the North Star

User journeys span multiple services and represent what users actually care about: can I complete checkout? Can I onboard successfully? User Journey SLOs answer these questions by aggregating signals across the services involved in a workflow. Composite SLOs (Section 3.3) are the primary mechanism for implementing User Journey SLOs, especially when end-to-end telemetry is difficult to instrument directly. These are the SLOs that should be visible in executive dashboards and tied to business KPIs. Set targets based on user expectations and business requirements, not internal infrastructure capabilities.


### 3.2.2 Application / Service SLOs Are the Unit of Ownership

Application / service-layer SLOs represent the reliability of individual services owned by a single team. They reflect the user's experience at the service boundary and answer the question: is this service performing within its contract? These SLOs drive operational alerting, error budget tracking, and team-level accountability. When a User Journey SLO degrades, application / service SLOs pinpoint which component is responsible.


### 3.2.3 Platform and Infrastructure SLOs Are Supporting Indicators

Platform and infrastructure SLOs serve two purposes. First, they provide leading indicators: a degradation at the infrastructure layer often precedes an application / service-layer impact, giving teams time to respond before users are affected. Second, they enable root cause attribution: when an application / service SLO is breached, platform and infrastructure SLOs help identify which layer is responsible.

Platform and infrastructure SLO targets should be more stringent than application / service SLO targets. If your application / service SLO is 99.9%, your platform SLO might be 99.95% and your infrastructure SLO 99.99%, because failures at lower layers cascade upward and compound.


### 3.2.4 Dependency SLOs Track What You Cannot Control

You cannot set an SLO on a service you do not control, but you can and should measure the reliability you observe from your side. Dependency SLOs provide data for vendor management conversations, help attribute application / service-layer budget consumption to external causes, and inform architecture decisions about circuit breakers, caching, and fallback strategies.

**Important:**

Create separate error budget tracking for dependencies. When a third-party outage consumes your application / service error budget, you need data to distinguish between internally-caused and externally-caused budget consumption.


## 3.3 Composite SLOs for Cross-Layer Visibility

Composite SLOs are the primary mechanism for implementing User Journey SLOs. They aggregate multiple individual SLOs into a single view that represents an end-to-end user workflow. This is especially valuable when end-to-end telemetry is difficult to instrument directly across service boundaries. A composite SLO for the checkout journey might combine an application / service-layer SLO (Checkout API availability), a platform-layer SLO (API Gateway latency), and an infrastructure-layer SLO (database availability), weighted to reflect each component's actual impact on the user experience.

> :material-book-open-variant: **Docs:** [Composite SLO Essentials](https://docs.nobl9.com/composites/essentials/)

**Composite SLO Design Guidelines:**

- Component SLOs must use consistent time windows and budgeting methods.
- Weights should reflect the real-world impact of each component. The application / service-layer component typically gets the highest weight because it is closest to the user.
- The composite target should account for cascading failures. If any critical component fails, the composite should reflect that.
- Use composite SLOs for executive reporting and user-journey-level health tracking. Use individual SLOs for operational alerting and team-level accountability.

## 3.4 Tiering in the Service Health Dashboard

Use the `layer` label to filter the Nobl9 Service Health Dashboard by architectural tier. This allows different audiences to see the view that matters to them:

- Executives and product managers: filter by `layer=user-journey` to see composite SLOs representing end-to-end workflow health.
- Service owners: filter by `layer=application` to see individual service health.
- Platform engineering: filter by `layer=platform` to see shared service health.
- Infrastructure teams: filter by `layer=infrastructure` to see compute, storage, and network health.
- Vendor management: filter by `layer=dependency` to see third-party reliability trends.

## 3.5 Tiering Applied: Error Budget Attribution

When a User Journey composite SLO breaches, the first step is to identify which application / service SLO is degraded. From there, attribution follows the layers downward. If the platform and infrastructure SLOs are healthy, the issue is in the application / service code. If a platform SLO is also degraded, the root cause is likely in that shared service. If an infrastructure SLO is breached, investigate the underlying cloud resources. If a dependency SLO shows degradation, the cause is external.

This attribution model directly informs who takes the lead on remediation and where the error budget consumption is charged. Document attribution rules in your error budget policy and review them during monthly SLO reviews.
