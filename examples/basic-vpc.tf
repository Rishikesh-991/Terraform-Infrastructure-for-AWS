# Example: Deploy a basic VPC with EC2 instance in dev environment
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "true"
      Project     = var.project_name
    }
  }
}

module "vpc" {
  source = "../terraform-aws-infra/modules/vpc"

  environment                  = var.environment
  vpc_cidr_block              = var.vpc_cidr_block
  number_of_availability_zones = 2
  public_subnet_bits          = 4
  private_subnet_bits         = 4

  tags = merge(
    var.common_tags,
    { Module = "vpc", Description = "Basic VPC example" }
  )
}

module "iam" {
  source = "../terraform-aws-infra/modules/iam"

  environment = var.environment

  tags = merge(
    var.common_tags,
    { Module = "iam" }
  )
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_summary" {
  value       = module.vpc.vpc_summary
  description = "VPC summary including subnet info"
}
