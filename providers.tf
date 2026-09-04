# providers.tf - Tell Terraform we are working with AWS

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# The provider block configures HOW to connect to AWS
# Credentials come from environment variables (AWS_ACCESS_KEY_ID, etc.)
provider "aws" {
  region = var.aws_region
}
