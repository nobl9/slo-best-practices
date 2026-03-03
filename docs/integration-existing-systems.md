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

The following example demonstrates ITSM integration using ServiceNow. Similar patterns apply to other ITSM tools using the Webhook alert method.

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

The following table illustrates a common routing pattern using Nobl9's built-in alert methods. Adapt the notification channels to match your organization's tooling:

| Nobl9 Alert | Example Notification Channels | Expected Response |
| --- | --- | --- |
| Budget exhausted | PagerDuty (high urgency) + ServiceNow incident | Declare incident. Engage on-call. Freeze non-critical deployments. |
| Fast burn (critical) | PagerDuty (high urgency) + Slack | Investigate immediately. Active incident affecting users. |
| Elevated burn (warning) | Slack team channel | Investigate within 1 hour. Check recent deployments. |
| Budget threshold | Slack + ServiceNow change request | Review error contributors. Consider deployment freeze. |
| No-data anomaly | Slack + PagerDuty (for critical tier) | Investigate data source connectivity. Check agent health. |

For specific burn-rate window configurations and thresholds, see Section 4.4.2. For error budget policy actions by budget status, see Section 5.5.3.


## 7.3 Team Messaging Integration Patterns

The following channel structure uses Slack as an example, but the same pattern applies to Microsoft Teams, Discord, or any team messaging platform:

- #slo-alerts-critical: High-urgency SLO alerts requiring immediate attention. Low-volume, high-signal.
- #slo-alerts-[team]: Team-specific SLO alerts and budget status notifications.
- #slo-reviews: Shared channel for posting weekly and monthly SLO review summaries and Nobl9 Oversight reminders.
- #slo-help: Support channel where teams ask questions about SLO configuration and best practices.

For centralized visibility into service reliability status, use the Nobl9 Service Health Dashboard as described in Section 3.4. For composite SLOs and executive-level reporting, see Section 3.3.
