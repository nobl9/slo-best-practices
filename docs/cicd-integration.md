# 6. CI/CD Integration and SLOs-as-Code

![](images/cicd-illustration.png)

Managing SLOs as code is the cornerstone of a scalable SLO practice. It brings the same rigor of version control, code review, and automated deployment that engineering teams apply to application code.


## 6.1 sloctl: The Nobl9 CLI

`sloctl` is the Nobl9 command-line tool for managing SLO definitions as YAML files. It supports creating, updating, and deleting all Nobl9 resources, dry-run validation before applying changes, filtering and querying resources by labels, and integration with CI/CD pipelines.

> :material-book-open-variant: **Docs:** [SLOs as Code](https://docs.nobl9.com/SLOs_as_code/)

> :material-book-open-variant: **Docs:** [sloctl on GitHub](https://github.com/nobl9/sloctl)


| Command | Description |
| --- | --- |
| sloctl apply -f slo.yaml | Creates or updates resources defined in the YAML file. |
| sloctl apply -f slo.yaml --dry-run | Validates the YAML without making changes. Essential for CI pipeline validation. |
| sloctl get slo -p my-project | Lists all SLOs in a project. |
| sloctl get slo -A -l team=checkout | Lists all SLOs across all projects matching the specified label. |
| sloctl delete slo my-slo -p my-project | Deletes an SLO. Use with caution in automated pipelines. |


## 6.2 Terraform Provider

For organizations using Terraform for infrastructure management, the Nobl9 Terraform provider provides a declarative way to manage Nobl9 resources alongside infrastructure. It supports projects, services, SLOs, alert policies, alert methods, and data sources using HCL or JSON configuration.

> :material-book-open-variant: **Docs:** [Nobl9 Terraform Provider](https://docs.nobl9.com/slos-as-code/terraform-provider/)

> :material-book-open-variant: **Docs:** [Terraform Registry: nobl9/nobl9](https://registry.terraform.io/providers/nobl9/nobl9/latest/docs)

> :material-book-open-variant: **Docs:** [Terraform SLO Resource Docs](https://registry.terraform.io/providers/nobl9/nobl9/latest/docs/resources/slo)


### 6.2.1 Terraform Provider Configuration


```hcl
# providers.tf
terraform {
  required_providers {
    nobl9 = {
      source  = "nobl9/nobl9"
      version = "~> 0.32"
    }
  }
}

provider "nobl9" {
  client_id     = var.nobl9_client_id
  client_secret = var.nobl9_client_secret
  organization  = var.nobl9_org_id
}
```


### 6.2.2 Terraform SLO Resource Example


```hcl
# slo.tf - Payments API Availability SLO
resource "nobl9_project" "checkout_team" {
  display_name = "Checkout Team"
  name         = "checkout-team"
  description  = "SLOs for the checkout engineering team"
  label {
    key    = "team"
    values = ["checkout"]
  }
  label {
    key    = "domain"
    values = ["payments"]
  }
}

resource "nobl9_service" "payments_api" {
  name         = "payments-api"
  display_name = "Payments API"
  project      = nobl9_project.checkout_team.name
  label {
    key    = "tier"
    values = ["critical"]
  }
  label {
    key    = "layer"
    values = ["application"]
  }
}

resource "nobl9_slo" "payments_api_availability" {
  name         = "payments-api-availability"
  display_name = "Payments API Availability"
  project      = nobl9_project.checkout_team.name
  service      = nobl9_service.payments_api.name
  budgeting_method = "Occurrences"

  label {
    key    = "tier"
    values = ["critical"]
  }
  label {
    key    = "layer"
    values = ["application"]
  }

  time_window {
    unit  = "Day"
    count = 30
    is_rolling = true
  }

  objective {
    display_name = "Availability"
    target       = 0.999
    value        = 1
    name         = "availability"
    raw_metric {
      query {
        datadog {
          query = "sum:http.requests.success{service:payments-api}.as_count()"
        }
      }
    }
    count_metrics {
      total {
        datadog {
          query = "sum:http.requests.total{service:payments-api}.as_count()"
        }
      }
      good {
        datadog {
          query = "sum:http.requests.success{service:payments-api}.as_count()"
        }
      }
    }
  }

  alert_policies = [
    nobl9_alert_policy.payments_fast_burn.name,
    nobl9_alert_policy.payments_slow_burn.name,
  ]
}
```


### 6.2.3 Terraform CI/CD Pipeline with GitHub Actions

The following GitHub Actions workflow automates Terraform-based SLO management with plan-on-PR and apply-on-merge:

**Example: .github/workflows/terraform-slos.yml**


```yaml
name: Terraform SLO Management
on:
  pull_request:
    paths: ['terraform/nobl9/**']
  push:
    branches: [main]
    paths: ['terraform/nobl9/**']

env:
  TF_VAR_nobl9_client_id: ${{ secrets.NOBL9_CLIENT_ID }}
  TF_VAR_nobl9_client_secret: ${{ secrets.NOBL9_CLIENT_SECRET }}
  TF_VAR_nobl9_org_id: ${{ secrets.NOBL9_ORG_ID }}

jobs:
  terraform-plan:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - name: Terraform Init
        run: terraform init
        working-directory: terraform/nobl9
      - name: Terraform Format Check
        run: terraform fmt -check -recursive
        working-directory: terraform/nobl9
      - name: Terraform Plan
        run: terraform plan -no-color
        working-directory: terraform/nobl9

  terraform-apply:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - name: Terraform Init
        run: terraform init
        working-directory: terraform/nobl9
      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: terraform/nobl9
```


## 6.3 sloctl CI/CD Pipeline with GitHub Actions

For organizations preferring YAML over HCL, the Nobl9 GitHub Action (nobl9/nobl9-action) provides a pre-built action that uses sloctl:

> :material-book-open-variant: **Docs:** [Nobl9 GitHub Actions](https://docs.nobl9.com/slos-as-code/ci-cd/github-actions/)

> :material-book-open-variant: **Docs:** [Nobl9 GitHub Action on Marketplace](https://github.com/marketplace/actions/nobl9-sloctl-action)

**Example: .github/workflows/sloctl-deploy.yml**


```yaml
name: Deploy SLO Definitions
on:
  pull_request:
    paths: ['slo-definitions/**']
  push:
    branches: [main]
    paths: ['slo-definitions/**']

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install yq
        run: |
          sudo wget -qO /usr/local/bin/yq \\
            https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
          sudo chmod +x /usr/local/bin/yq
      - name: Lint Labels
        run: |
          bash scripts/lint-slo-labels.sh \\
            $(find slo-definitions -name '*.yaml' -type f)
      - name: Dry Run Validation
        uses: nobl9/nobl9-action@v1
        with:
          client_id: ${{ secrets.NOBL9_CLIENT_ID }}
          client_secret: ${{ secrets.NOBL9_CLIENT_SECRET }}
          sloctl_yml: slo-definitions/
          dry_run: true

  deploy:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - name: Get Changed Files
        id: changed
        run: |
          FILES=$(git diff --name-only HEAD~1 HEAD -- slo-definitions/)
          echo "files=$FILES" >> $GITHUB_OUTPUT
      - name: Apply Changed Definitions
        uses: nobl9/nobl9-action@v1
        with:
          client_id: ${{ secrets.NOBL9_CLIENT_ID }}
          client_secret: ${{ secrets.NOBL9_CLIENT_SECRET }}
          sloctl_yml: ${{ steps.changed.outputs.files }}
```


## 6.4 Repository Structure


```
slo-definitions/
  projects/
    checkout-team/
      project.yaml
      services/
        payments-api.yaml
      slos/
        payments-api-availability.yaml
        payments-api-latency.yaml
      alert-policies/
        payments-api-fast-burn.yaml
        payments-api-slow-burn.yaml
  shared/
    alert-methods/
      slack-sre.yaml
      pagerduty-critical.yaml
      servicenow-itsm.yaml
  scripts/
    lint-slo-labels.sh
  policy/
    labels.rego              # Conftest policy
```


## 6.5 GitOps Best Practices

- Store all SLO definitions in a dedicated repository or a clearly defined directory within your monorepo.
- Use branch protection rules to require code reviews on SLO changes.
- Run sloctl apply --dry-run and label linting on every pull request as mandatory CI checks.
- Apply only changed files on merge to main (the Procore pattern). This future-proofs the pipeline as you scale.
- Automate SLO annotation creation in your deployment pipeline to mark each deployment on the SLO timeline.
- Tag SLO definition changes with version numbers to track changes over time.