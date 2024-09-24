data "aws_caller_identity" "current" {}

locals {
  project_prefix = "${var.project}-${terraform.workspace}"
  s3_bucket_name = "${local.project_prefix}-bucket"
  account_id     = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket" "this" {
  bucket        = local.s3_bucket_name
  force_destroy = false

  tags = merge(
    {
      Name        = local.s3_bucket_name
      Environment = terraform.workspace
    },
    var.default_tags
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this,
  ]

  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Disabled"
  }
}
