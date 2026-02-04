resource "aws_s3_bucket" "this" {
  count = var.create ? 1 : 0
  bucket = var.bucket_name != "" ? var.bucket_name : "${var.environment}-bucket-${substr(md5(timestamp()),0,6)}"
  acl = "private"
  tags = var.tags
}

resource "aws_cloudfront_distribution" "cdn" {
  count = var.create && var.enable_cloudfront ? 1 : 0
  enabled = true
  origins = []
}
