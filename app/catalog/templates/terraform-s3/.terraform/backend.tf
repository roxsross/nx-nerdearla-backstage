terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "org-statebucket"
    key    = "${{ values.name }}/terraform.tfstate"
    region = "${{ values.region }}"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "${{ values.region }}"
}
