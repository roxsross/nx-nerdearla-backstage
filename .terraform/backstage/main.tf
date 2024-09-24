data "aws_caller_identity" "current" {}

locals {
  project_prefix = "${var.project}-${terraform.workspace}"
  account_id     = data.aws_caller_identity.current.account_id
  s3_bucket_name = "${local.project_prefix}-${var.region}-${local.account_id}"
}

resource "aws_s3_bucket" "backstage" {
  bucket        = local.s3_bucket_name
  force_destroy = true

  tags = merge(
    {
      Name        = local.s3_bucket_name
      Environment = terraform.workspace
    },
    var.default_tags
  )
}

resource "aws_s3_bucket_ownership_controls" "backstage" {
  bucket = aws_s3_bucket.backstage.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "backstage" {
  bucket = aws_s3_bucket.backstage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "backstage" {
  depends_on = [
    aws_s3_bucket_ownership_controls.backstage,
    aws_s3_bucket_public_access_block.backstage,
  ]

  bucket = aws_s3_bucket.backstage.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "backstage" {
  bucket = aws_s3_bucket.backstage.id
  versioning_configuration {
    status = "Disabled"
  }
}
