output "s3_bucket" {
  value = aws_s3_bucket.hosting.bucket
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_distribution_domain" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}