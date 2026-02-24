# Nobl9 SLO Deployment Best Practices Guide

Enterprise Rollout Strategies & Operational Playbook for deploying Nobl9 SLOs at scale.

## What's in this guide

| Section | Topic |
|---------|-------|
| 1. Introduction | Who this is for, how to use it, the case for SLOs |
| 2. Platform Configuration | Projects, services, labels, annotations, data sources, naming conventions |
| 3. SLO Tiering Strategy | Four-layer model, composite SLOs, error budget attribution |
| 4. SLO Lifecycle (SLODLC) | Initiate → Discover → Design → Implement → Operate |
| 5. Ownership & Governance | Roles, RBAC, security best practices, SLO Oversight, review cycles |
| 6. CI/CD Integration | sloctl, Terraform provider, GitHub Actions pipelines, label linting |
| 7. Integration | Alert methods (Slack, PagerDuty, ServiceNow), dashboards, composite SLOs |
| 8. Operational Playbooks | Onboarding, error budget exhaustion, quarterly review, new SLO checklists |
| 9. Common Pitfalls | 10 most common mistakes and how to avoid them |
| 10. Appendices | SLO specification template, SLODLC checklist, 80+ reference links |

## View the guide

The guide is published at: **https://nobl9.github.io/slo-best-practices/**

## Edit the guide

All content lives in `docs/` as Markdown files. To edit:

1. Edit any `.md` file in `docs/` directly on GitHub or locally
2. Open a pull request — the CI will build a preview
3. Merge to `main` — the site deploys automatically via GitHub Pages

## Local development

```bash
# Install MkDocs Material
pip install mkdocs-material

# Serve locally with hot-reload
mkdocs serve

# Build static site
mkdocs build
```

The site will be available at `http://localhost:8000`.

## Files

```
docs/                          ← Markdown source (edit these)
  index.md                     ← Introduction (home page)
  platform-configuration.md    ← Section 2
  slo-tiering.md               ← Section 3
  slo-lifecycle.md             ← Section 4
  ownership-governance.md      ← Section 5
  cicd-integration.md          ← Section 6
  integration-existing-systems.md ← Section 7
  operational-playbooks.md     ← Section 8
  common-pitfalls.md           ← Section 9
  appendices.md                ← Section 10
  stylesheets/extra.css        ← Nobl9 brand theming
mkdocs.yml                     ← Site configuration & navigation
.github/workflows/deploy.yml   ← Auto-deploy on push to main
```
