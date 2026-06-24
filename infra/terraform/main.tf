# main.tf
# ─────────────────────────────────────────────────────────────────────────────
# Root module entry point for the DevOps Lab IaC demo.
#
# Design choices:
#   • Uses the null + random providers — no cloud credentials required.
#     The layout, variable patterns, locals strategy, and module structure
#     mirror production Terraform so reviewers can evaluate IaC competency
#     without needing AWS/Azure/GCP access.
#   • All resource logic lives in ./modules/app-config so the root module
#     stays thin: it wires variables, locals, and module calls only.
#   • random_id gives each workspace a stable, unique deployment identifier
#     that survives plan/apply cycles (stored in state).
# ─────────────────────────────────────────────────────────────────────────────

# ── Stable workspace identity ─────────────────────────────────────────────────
# byte_length = 4 → 8 hex chars, e.g. "a3f2b1c0".
# The value is written to state on first apply and never regenerated unless
# the resource is explicitly tainted or destroyed.
resource "random_id" "workspace" {
  byte_length = 4

  keepers = {
    # Rotating the app_name or environment intentionally resets the ID.
    app_name    = var.app_name
    environment = var.environment
  }
}

# ── App configuration module ──────────────────────────────────────────────────
# Encapsulates the null_resource lifecycle simulation and config-drift
# detection logic. Keeping this in a child module means the same pattern can
# be reused for multiple services by calling the module multiple times with
# different inputs.
module "app_config" {
  source = "./modules/app-config"

  app_name      = var.app_name
  environment   = var.environment
  replica_count = var.replica_count
  common_tags   = local.common_tags
}
