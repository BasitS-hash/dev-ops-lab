# variables.tf
# ─────────────────────────────────────────────────────────────────────────────
# All input variables for the root module.
# Consumers set these via terraform.tfvars, -var flags, or environment
# variables (TF_VAR_*). Defaults make the module runnable out of the box
# without any external configuration — ideal for CI and local demos.
# ─────────────────────────────────────────────────────────────────────────────

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod). Used in resource naming and tagging."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "app_name" {
  description = "Logical application name. Used as a prefix in resource labels and output values."
  type        = string
  default     = "devops-lab"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.app_name))
    error_message = "app_name must be lowercase alphanumeric with hyphens, 3-30 characters."
  }
}

variable "replica_count" {
  description = "Number of application replicas to simulate. Demonstrates numeric variable constraints."
  type        = number
  default     = 2

  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 10
    error_message = "replica_count must be between 1 and 10."
  }
}

variable "tags" {
  description = "Additional resource tags to merge with the defaults computed in locals.tf. Keys and values must be strings."
  type        = map(string)
  default     = {}
}
