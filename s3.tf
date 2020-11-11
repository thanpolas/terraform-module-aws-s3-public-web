#
# S3 Bucket for web.
#

resource "aws_s3_bucket" "web" {
  bucket = var.name
  acl    = "public-read"

  force_destroy = false

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://${var.target_hostname}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.name}/*"
        }
    ]
}
POLICY

  tags = {
    Name = "${var.name}-s3-bucket"
  }

  provider = aws.main
}

# Public access restriction
resource "aws_s3_bucket_public_access_block" "web" {
  bucket = aws_s3_bucket.web.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = false

  provider = aws.main
}
