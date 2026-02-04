output "bucket_id" { value = try(aws_s3_bucket.this[0].id, "") }
output "cloudfront_id" { value = try(aws_cloudfront_distribution.cdn[0].id, "") }
