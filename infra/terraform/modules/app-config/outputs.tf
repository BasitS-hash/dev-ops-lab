# modules/app-config/outputs.tf
# ─────────────────────────────────────────────────────────────────────────────
# Outputs exported from the app-config child module back to the root module.
# The root module references these as module.app_config.<output_name>.
# ─────────────────────────────────────────────────────────────────────────────

output "deployment_label" {
  description = "Human-readable identifier combining environment and app_name. Suitable for log correlation, CI annotations, and dashboard labels."
  value       = "${var.environment}/${var.app_name}"
}

output "config_resource_id" {
  description = "Terraform resource ID of the null_resource sentinel. Use as a depends_on target in modules that must run after this config is applied."
  value       = null_resource.app_config.id
}

output "effective_replica_count" {
  description = "The replica count currently tracked in state. Useful for verifying that scaling changes were applied."
  value       = var.replica_count
}
