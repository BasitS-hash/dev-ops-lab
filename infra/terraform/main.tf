// Terraform scaffold - configure a provider before use
// Example (AWS):
// provider "aws" {
//   region = var.region
// }

terraform {
  required_version = ">= 1.0.0"
}

// A safe, no-op example resource so `terraform init` and `plan` work
resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo 'Terraform scaffold: configure a provider to create real resources'"
  }
}
