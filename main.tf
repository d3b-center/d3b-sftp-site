data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
