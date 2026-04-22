locals {
  tags = {
    environment = terraform.workspace
    project     = "wordpress"
    managed_by  = "Terraform"
  }
}

