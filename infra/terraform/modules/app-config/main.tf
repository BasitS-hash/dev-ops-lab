# modules/app-config/main.tf
# ─────────────────────────────────────────────────────────────────────────────
# App-config module — simulates application configuration lifecycle management.
#
# The null_resource pattern demonstrated here is a standard technique for:
#   1. Config drift detection — any change to the tracked values causes
#      Terraform to mark the resource as "must replace", forcing a re-apply.
#   2. Lifecycle hooks — provisioners (local-exec, remote-exec) can run
#      scripts at create/destroy time, e.g. registering a service with a
#      catalog or draining traffic before teardown.
#   3. Cross-module signalling — other modules can depend_on this resource
#      to sequence their apply order without a direct data reference.
#
# In a real workload, this pattern wraps external API calls, Helm releases,
# Ansible playbook executions, or custom operator reconciliation steps that
# Terraform cannot model natively.
# ─────────────────────────────────────────────────────────────────────────────

# ── Config-drift sentinel ─────────────────────────────────────────────────────
# triggers is a map of arbitrary key/value pairs. Terraform computes a diff
# against the state on every plan. If any value changes, the resource is
# marked tainted and will be destroyed + recreated on the next apply — this
# is the "drift detection" pattern.
resource "null_resource" "app_config" {
  triggers = {
    # Core identity — renaming the app or changing the environment forces a
    # full reconfiguration cycle (analogous to a blue/green cutover).
    app_name    = var.app_name
    environment = var.environment

    # Scaling signal — changing replica_count triggers the sentinel, which in
    # a real module would invoke a scaling API or update a manifest.
    replica_count = tostring(var.replica_count)

    # Tag fingerprint — serialising the tag map detects any metadata change,
    # e.g. adding a CostCenter tag mid-quarter.
    tags_checksum = md5(jsonencode(var.common_tags))
  }

  # ── Lifecycle hook (creation) ───────────────────────────────────────────────
  # local-exec runs on the machine executing `terraform apply`.
  # Replace this command with a real deployment script, kubectl apply,
  # helm upgrade, or API call in production.
  provisioner "local-exec" {
    command = <<-EOT
      echo "[app-config] Applying config for '${var.app_name}' in '${var.environment}'"
      echo "[app-config] Replica target: ${var.replica_count}"
    EOT
  }

  # ── Lifecycle hook (teardown) ───────────────────────────────────────────────
  # when = destroy runs before the resource is removed from state.
  # Use this for drain/deregister/cleanup logic.
  provisioner "local-exec" {
    when    = destroy
    command = "echo '[app-config] Tearing down configuration - draining replicas'"
  }
}
