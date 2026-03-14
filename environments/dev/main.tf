terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "nolan-terraform-state"
    key            = "terraform/day6/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
    profile        = "terraform-lab"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "terraform-lab"
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project}-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id
}

module "s3_bucket" {
  source      = "../../modules/s3-bucket"
  bucket_name = "${local.name_prefix}-${local.account_id}-bucket"
}

module "dynamodb_table" {
  source     = "../../modules/dynamodb-table"
  table_name = "${local.name_prefix}-table"
  hash_key   = "LockID"
}

output "bucket_name" {
  value = module.s3_bucket.bucket_name
}

output "dynamodb_table_name" {
  value = module.dynamodb_table.table_name
}
