terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = { source = "hashicorp/aws" }
    random = { source = "hashicorp/random" }
  }

   backend "s3" {
    bucket         = "my-terraform-state-bucket-het"
    key            = "three-tier/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}