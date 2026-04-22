terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.40.0"
    }
  }

  backend "s3" {
    bucket    = "backend-ah-state"
    key       = "prod/terraform.tfstate"
    use_lockfile = "true"
    region    = "eu-west-2"
  }

}

provider "aws" {
  region = var.region
}

