data "aws_caller_identity" "current" {}

locals {
  project_prefix = "${var.project}-${terraform.workspace}"
  account_id     = data.aws_caller_identity.current.account_id
}

resource "aws_ecr_repository" "backstage" {
  name = local.project_prefix

  image_tag_mutability = "MUTABLE"

  force_delete = true
  
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    {
      Name        = local.project_prefix
      Environment = terraform.workspace
    },
    var.default_tags
  )
}
