# versions.tf
# ─────────────────────────────────────────────────────────────────────────────
# Pin Terraform core and every provider used by this workspace.
# Using ~> (pessimistic constraint) allows patch/minor bumps while protecting
# against breaking major-version changes — a best practice for reproducible
# IaC pipelines.
# ─────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # hashicorp/null — lightweight "no-op" provider used to model lifecycle
    # hooks, triggers, and config-drift detection without cloud credentials.
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }

    # hashicorp/random — generates stable pseudo-random values (UUIDs, IDs)
    # that are stored in state and remain constant across plan/apply cycles.
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
