# 7. Integration with Existing Systems

Nobl9 is designed to complement your existing operational tooling, not replace it. This section covers how to integrate Nobl9 with your alerting, communication, and incident management systems.


## 7.1 Alert Methods

> :material-book-open-variant: **Docs:** [Alert Methods Overview](https://docs.nobl9.com/alerting/alert-methods/)


| Alert Method | Use Case | Configuration Notes |
| --- | --- | --- |
| Slack | Team-level notifications for warning-level alerts and budget status updates. | Create a dedicated SLO channel per team (e.g., #slo-checkout-team). Avoid sending alerts to general engineering channels. |
| PagerDuty | Critical alerts requiring immediate human response, integrated with on-call schedules. | Use the PagerDuty Integration Key. Map critical burn-rate alerts to high-urgency incidents. Nobl9 sends resolution all-clear messages. |
| ServiceNow | ITSM ticket creation for budget threshold violations, change management integration, and audit trail. | Requires ServiceNow instance name, username, and password. Set up a dedicated ACL. Nobl9 maps its severity levels to ServiceNow event severity. |
| Discord | Alternative to Slack for organizations using Discord for team communication. | Similar configuration to Slack. Create dedicated channels for SLO notifications. |
| Webhook | Custom integrations with internal tools, ticketing systems (Jira), or automation platforms. | Use webhooks to trigger automated responses, create tickets, or feed data into custom dashboards. |


### 7.1.1 ServiceNow Integration Details

The Nobl9-ServiceNow integration creates incidents in your ServiceNow instance when SLO-based alerts fire. This is particularly valuable for organizations that use ServiceNow as their system of record for incident management and change management. Configuration requires your ServiceNow instance name, a service account with appropriate ACL permissions, and a project assignment in Nobl9. Nobl9 maps its alert severities to ServiceNow event severity levels automatically.

> :material-book-open-variant: **Docs:** [ServiceNow Alert Method](https://docs.nobl9.com/alerting/alert-methods/servicenow/)

**ServiceNow Alert Method YAML:**


```yaml
apiVersion: n9/v1alpha
kind: AlertMethod
metadata:
  name: servicenow-itsm
  displayName: ServiceNow ITSM Alerts
  project: shared-alerts
spec:
  description: Route SLO alerts to ServiceNow for ITSM tracking
  servicenow:
    username: nobl9-integration
    password: "$SERVICENOW_PASSWORD"  # Use secrets management
    instanceName: company-prod
    sendResolution:
      message: "SLO alert resolved - error budget recovering"
```


### 7.1.2 Alert Method Testing

Nobl9 provides built-in testing for all alert methods. After configuring an alert method, use the test feature to verify notifications are delivered correctly before relying on them for production alerting.


## 7.2 Mapping Alert Severity to Response


| Nobl9 Alert | Notification Channels | Expected Response |
| --- | --- | --- |
| Budget exhausted | PagerDuty (high urgency) + ServiceNow incident | Declare incident. Engage on-call. Freeze non-critical deployments. |
| Fast burn (20x+ / 5 min) | PagerDuty (high urgency) + Slack | Investigate immediately. Active incident affecting users. |
| Elevated burn (2x-5x / 6 hr) | Slack team channel | Investigate within 1 hour. Check recent deployments. |
| Budget below 25% | Slack + ServiceNow change request | Add to next standup. Review error contributors. Consider freeze. |
| No-data anomaly | Slack + PagerDuty (for critical tier) | Investigate data source connectivity. Check agent health. |


## 7.3 Slack Integration Patterns

For Slack integration, we recommend the following channel structure:

- #slo-alerts-critical: High-urgency SLO alerts requiring immediate attention. Low-volume, high-signal.
- #slo-alerts-[team]: Team-specific SLO alerts and budget status notifications.
- #slo-reviews: Shared channel for posting weekly and monthly SLO review summaries and Nobl9 Oversight reminders.
- #slo-help: Support channel where teams ask questions about SLO configuration and best practices.

## 7.4 Service Health Dashboard

The Nobl9 Service Health Dashboard provides a centralized view of all services and their SLO status. Use it as the starting point for operational reviews and incident triage. The dashboard groups services under projects, shows color-coded status indicators (red, yellow, green), and can be filtered by labels to focus on specific teams, tiers, layers, or regions. Use the layer label to create tier-specific views as described in Section 3.4.


## 7.5 Composite SLOs for Executive Reporting

Composite SLOs aggregate individual SLOs into a single view representing end-to-end user journeys. They are the primary mechanism for executive-level reliability reporting. A checkout user journey composite might combine SLOs from the cart service (application layer), the API gateway (platform layer), and the database (infrastructure layer), weighted by their relative impact on the user experience. Refer to Section 3.3 for design guidelines.

> :material-book-open-variant: **Docs:** [Composite SLO Essentials](https://docs.nobl9.com/composites/essentials/)

> :material-book-open-variant: **Docs:** [Composite SLOs Guide](https://docs.nobl9.com/guides/slo-guides/composite-guide/)
