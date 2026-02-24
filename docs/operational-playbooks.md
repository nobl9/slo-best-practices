# 8. Operational Playbooks

This section provides detailed, actionable checklists for common operational scenarios. Each playbook is designed to be printed or bookmarked as a standalone reference.


## 8.1 New Team Onboarding Checklist

**Phase 1: Pre-Onboarding (1 week before kickoff)**

- [ ] Identify the SLO Champion for the team
- [ ] Schedule a 1-hour kickoff meeting with the full team
- [ ] Share pre-reading materials: Nobl9 documentation, SLODLC handbook, this guide
- [ ] Create the team's project in Nobl9 with proper naming convention
- [ ] Configure RBAC: assign Project Owner to SLO Champion, Project Viewer to all team members
- [ ] Verify that the team's monitoring tools are supported by Nobl9
- [ ] Pre-create the data source connection and verify it returns data
**Phase 2: Kickoff Meeting**

- [ ] Present the SLO program overview and business case
- [ ] Walk through the tiering model and where the team's services fit
- [ ] Discuss the team's services and identify 2-3 initial SLO candidates
- [ ] Review the label taxonomy and annotation requirements
- [ ] Agree on review cadence (weekly operational, monthly target review)
- [ ] Assign action items: who will draft the first SLO definitions
**Phase 3: First SLOs (Week 1)**

- [ ] Use AI-assisted discovery (Section 4.2.1) to generate initial SLO YAML from codebase
- [ ] Review and refine AI-generated YAML with the team
- [ ] Use the SLI Analyzer to validate that queries return expected data
- [ ] Confirm initial targets are reasonable based on historical data
**Phase 4: Alert Configuration (Week 2)**

- [ ] Create fast-burn alert policy (20x / 5 min) using Nobl9 preset
- [ ] Create slow-burn alert policy (2x / 6 hr) using Nobl9 preset
- [ ] Create budget threshold alerts (25% and 10%)
- [ ] Configure no-data anomaly alerts based on service tier
- [ ] Connect alert methods: Slack channel for the team, PagerDuty for critical
- [ ] If using ServiceNow, configure the ServiceNow alert method
- [ ] Test all alert methods using the Nobl9 built-in test feature
- [ ] Document alert routing in the team's runbook
**Phase 5: CI/CD Setup (Week 2-3)**

- [ ] Create the team's directory in the SLO definitions repository
- [ ] Move all YAML definitions into the repository structure
- [ ] Add the label linting script and Conftest policies if applicable
- [ ] Configure the CI/CD pipeline (GitHub Actions or equivalent)
- [ ] Verify dry-run validation passes in CI for a test PR
- [ ] Merge the first PR and verify definitions are applied successfully
- [ ] Add deployment annotation automation to the team's deploy pipeline
**Phase 6: Operational Readiness (Week 3-4)**

- [ ] Conduct the first weekly SLO review with the team
- [ ] Verify error budget tracking is working as expected
- [ ] Set up the Nobl9 SLO Oversight review schedule for the team's SLOs
- [ ] Document the team's error budget policy
- [ ] Ensure all metadata annotations are populated (runbook, oncall, repo, owner)
- [ ] Add the team's SLOs to the cross-team review dashboard
- [ ] Conduct a 30-day check-in to review initial targets and adjust
- [ ] Schedule the handoff: team is now self-sufficient, platform team provides support as needed
**Phase 7: Handoff Validation**

- [ ] SLO Champion can independently create and modify SLO definitions via code
- [ ] Team understands and follows the review cadence
- [ ] Alert routing is tested and confirmed working
- [ ] Error budget policy is documented and agreed upon
- [ ] Team has access to and understands the Service Health Dashboard
- [ ] Onboarding retrospective completed: lessons learned documented for next team

## 8.2 Error Budget Exhaustion Checklist

**Step 1: Acknowledge and Verify (within 15 minutes)**

- [ ] Confirm the budget exhaustion alert is not a false positive or data quality issue
- [ ] Check the Nobl9 SLO detail page to understand the consumption pattern
- [ ] Determine if this is caused by a single incident or gradual degradation
- [ ] Check for no-data anomalies that might be masking the real data
**Step 2: Communicate (within 30 minutes)**

- [ ] Notify the team via the designated Slack channel
- [ ] Post the current error budget percentage and burn rate
- [ ] If caused by a single incident, link to the incident channel or postmortem
- [ ] Brief the engineering manager
- [ ] If ServiceNow is configured, verify an incident has been created
**Step 3: Triage (within 2 hours)**

- [ ] Review the last 7 days of error budget consumption on the SLO timeline
- [ ] Check SLO annotations for recent deployments, rollbacks, or config changes
- [ ] Identify the top contributors to budget consumption
- [ ] Check platform and infrastructure layer SLOs for cascading issues (Section 3.5)
- [ ] Check dependency layer SLOs for external causes
- [ ] Review the Nobl9 Alert Center for related alerts across services
**Step 4: Remediate**

- [ ] Implement the error budget policy: freeze non-critical deployments
- [ ] If a recent deployment caused the issue, evaluate whether to rollback
- [ ] Create action items for the top error contributors
- [ ] Assign owners to each action item with deadlines
- [ ] If cross-team dependencies are involved, engage the SLO Process Owner
**Step 5: Monitor Recovery**

- [ ] Track burn rate daily to confirm it is below 1x (budget is recovering)
- [ ] Hold daily standups focused on reliability until the budget is above 10%
- [ ] Create SLO annotations marking remediation actions taken
**Step 6: Review (within 1 week)**

- [ ] Conduct a formal review of the incident and budget exhaustion
- [ ] Evaluate whether the SLO target was appropriate
- [ ] Update the SLO target if the review reveals it was unrealistic
- [ ] Update alert thresholds if early warning was insufficient
- [ ] Document lessons learned in the team's knowledge base
- [ ] Update the runbook with any new troubleshooting steps
- [ ] Close the ServiceNow incident with resolution details

## 8.3 Quarterly SLO Program Review Checklist

**Step 1: Preparation (1 week before review)**

- [ ] Gather cross-service SLO reports from Nobl9 for the quarter
- [ ] Compile composite SLO performance for key user journeys
- [ ] Count error budget violations and their business impact
- [ ] Assess adoption metrics: number of teams, services, SLOs, and active review cycles
- [ ] Identify any Overdue SLO reviews in Nobl9 Oversight
- [ ] Pull label compliance metrics from CI/CD pipeline logs
- [ ] Prepare a summary of data anomalies (no-data, constant-burn, no-burn)
**Step 2: Maturity Assessment**

- [ ] Compare current state to the maturity model (Section 4.1.3)
- [ ] Identify areas where the program is ahead of or behind expectations
- [ ] Evaluate RBAC configuration: are roles still appropriate?
- [ ] Review the label taxonomy: are new labels needed? Are any unused?
- [ ] Assess CI/CD pipeline health: are all teams using automated validation?
**Step 3: Target Evaluation**

- [ ] Identify SLOs consistently over-achieving (error budget barely consumed)
- [ ] Identify SLOs consistently under-achieving (budget frequently exhausted)
- [ ] For over-achievers: recommend tightening targets to provide useful signal
- [ ] For under-achievers: determine if targets are unrealistic or if systemic issues exist
- [ ] Review composite SLO weights: do they still reflect actual user impact?
**Step 4: Plan Next Quarter**

- [ ] Define adoption goals: how many new teams and services to onboard
- [ ] Identify platform improvements needed (new integrations, better automation)
- [ ] Allocate resources for team onboarding and training
- [ ] Set improvement targets for alert precision and review compliance
- [ ] Schedule next quarter's strategic review date
- [ ] Publish the quarterly report to all stakeholders

## 8.4 New SLO Creation Checklist

**Prerequisites**

- [ ] Service exists in Nobl9 with proper labels (team, tier, layer, env)
- [ ] Metadata annotations populated (owner, runbook, oncall, repo)
- [ ] Data source connection is active and tested
- [ ] User journey mapped and SLI candidates identified
**Design**

- [ ] SLI type selected (availability, latency, throughput, correctness)
- [ ] Budgeting method selected (occurrences or time slices)
- [ ] Target set based on historical baseline data (use SLI Analyzer)
- [ ] Time window configured (rolling for alerting, calendar-aligned for reviews)
- [ ] SLO specification template filled out (Appendix A)
**Implementation**

- [ ] YAML definition created with all required labels and annotations
- [ ] Label linting passes
- [ ] sloctl apply --dry-run passes
- [ ] Code review approved by at least one team member
- [ ] Applied to Nobl9 via CI/CD pipeline
- [ ] Verified in the Service Health Dashboard that data is flowing
**Alert Configuration**

- [ ] Fast-burn alert policy attached (20x / 5 min)
- [ ] Slow-burn alert policy attached (2x / 6 hr)
- [ ] Budget threshold alerts configured (25% and 10%)
- [ ] No-data anomaly alert configured based on service tier
- [ ] All alert methods tested
**Governance**

- [ ] Review schedule configured in Nobl9 SLO Oversight
- [ ] SLO added to the team's review cadence
- [ ] Error budget policy documented and communicated
- [ ] SLO Champion confirms ownership