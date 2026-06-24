# outputs.tf
# ─────────────────────────────────────────────────────────────────────────────
# Root-module outputs surface values for downstream consumers such as:
#   • other Terraform workspaces (via terraform_remote_state)
#   • CI pipelines reading `terraform output -json`
#   • documentation and runbook generation
# ─────────────────────────────────────────────────────────────────────────────

output "app_name" {
  description = "The application name as provided by var.app_name."
  value       = var.app_name
}

output "environment" {
  description = "The deployment environment (dev | staging | prod)."
  value       = var.environment
}

output "replica_count" {
  description = "Number of simulated application replicas configured for this workspace."
  value       = var.replica_count
}

output "deployment_id" {
  description = "Stable hex identifier for this Terraform workspace, generated once and stored in state."
  value       = local.deployment_id
}

output "deployment_label" {
  description = "Human-readable label returned by the app-config module, combining environment and app name."
  value       = module.app_config.deployment_label
}

output "name_prefix" {
  description = "Naming prefix used for resources in this workspace (format: <app_name>-<environment>)."
  value       = local.name_prefix
}

output "common_tags" {
  description = "The merged tag map applied to all resources in this workspace."
  value       = local.common_tags
}
