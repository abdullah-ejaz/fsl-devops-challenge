#####################
# Hosting Bucket
#####################

resource "aws_s3_bucket" "hosting" {
  bucket = "${var.app_name}-${var.environment}-hosting-bucket"
  force_destroy = true

  tags = {
    Project = "FSL DevOps"
  }
}

########################
# CloudFront Distribtion
########################

resource "aws_cloudfront_origin_access_control" "hosting_oac" {
  name                              = "fsl-devops-task"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.hosting.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.hosting_oac.id
    origin_id                = "S3-${aws_s3_bucket.hosting.bucket}"
  }

  enabled             = true
  comment             = "FSL DevOps CloudFront"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logging.bucket_domain_name
    prefix          = ""
  }


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.hosting.bucket}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["PK"]
    }
  }

  tags = {
    Project = "FSL DevOps"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Logging Bucket
resource "aws_s3_bucket" "logging" {
  bucket = "${var.app_name}-${var.environment}-logging-bucket"
  force_destroy = true

  tags = {
    Project = "FSL DevOps"
  }
}

resource "aws_s3_bucket_ownership_controls" "logging" {
  bucket = aws_s3_bucket.logging.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logging" {
  depends_on = [aws_s3_bucket_ownership_controls.logging]

  bucket = aws_s3_bucket.logging.id
  acl    = "private"
}

########################
# IAM Policies
########################

# hosting bucket
resource "aws_s3_bucket_policy" "hosting" {
  bucket = aws_s3_bucket.hosting.id
  policy = data.aws_iam_policy_document.hosting.json
}

data "aws_iam_policy_document" "hosting" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.hosting.arn,
      "${aws_s3_bucket.hosting.arn}/*",
    ]
  }
}

# logging bucket

resource "aws_s3_bucket_policy" "logging" {
  bucket = aws_s3_bucket.logging.id
  policy = data.aws_iam_policy_document.logging.json
}

data "aws_iam_policy_document" "logging" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetBucketAcl",
      "s3:PutBucketAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.logging.arn,
      "${aws_s3_bucket.logging.arn}/*",
    ]
  }
}