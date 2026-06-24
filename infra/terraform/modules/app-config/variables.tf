# modules/app-config/variables.tf
# ─────────────────────────────────────────────────────────────────────────────
# Input variable declarations for the app-config child module.
# These mirror a subset of the root module's variables — modules declare
# their own inputs rather than inheriting from the parent directly, which
# keeps modules self-contained and reusable across workspaces.
# ─────────────────────────────────────────────────────────────────────────────

variable "app_name" {
  description = "Application name passed from the root module. Used in trigger keys and output labels."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod). Combined with app_name to form the deployment label."
  type        = string
}

variable "replica_count" {
  description = "Number of application replicas to simulate. Stored as a trigger so Terraform detects drift when the value changes."
  type        = number
}

variable "common_tags" {
  description = "Merged tag map from the root module locals. Stored in the null_resource trigger to surface tag changes as drift."
  type        = map(string)
}
