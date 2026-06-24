# locals.tf
# ─────────────────────────────────────────────────────────────────────────────
# Local values are computed once and referenced throughout the module.
# They centralise logic that would otherwise be duplicated across resources —
# the primary tool for DRY tagging strategies in production Terraform.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  # ── Tagging strategy ────────────────────────────────────────────────────────
  # Start with opinionated defaults every resource must carry, then merge in
  # any caller-supplied tags. Caller tags win on collision so consumers can
  # override (e.g. set their own "Owner" or "CostCenter" values).
  default_tags = {
    Environment = var.environment
    Application = var.app_name
    ManagedBy   = "terraform"
    Repository  = "dev-ops-lab"
  }

  common_tags = merge(local.default_tags, var.tags)

  # ── Naming convention ────────────────────────────────────────────────────────
  # Build a consistent name prefix used across resources and module outputs.
  # Format: <app_name>-<environment>  →  devops-lab-dev
  name_prefix = "${var.app_name}-${var.environment}"

  # ── Deployment identifier ────────────────────────────────────────────────────
  # random_id (declared in main.tf) produces a stable hex token written to
  # Terraform state on first apply. Subsequent plans reuse the stored value,
  # so the ID is immutable for the lifetime of a workspace — useful as a
  # correlation handle in logs, dashboards, and CI annotations.
  deployment_id = random_id.workspace.hex
}
