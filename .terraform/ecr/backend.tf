terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "terraform-state-bucket-gbzfds"
    key    = "backstage-ecr/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
