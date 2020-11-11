#
# IAM for deploying to the S3 web resource.
#

# User for CircleCI demo frontend deployments
resource "aws_iam_user" "web" {
  name          = "user-web-${var.target_hostname}"
  force_destroy = true

  provider = aws.main
}

# Policy with HTTP Basic Auth
data "aws_iam_policy_document" "web_basic_authentication" {
  count = length(var.authentication) > 0 ? 1 : 0

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.web.arn,
      "${aws_s3_bucket.web.arn}/*",
    ]
  }

  statement {
    actions = ["cloudfront:CreateInvalidation"]

    resources = [
      aws_cloudfront_distribution.web_basic_authentication.0.arn,
    ]
  }

  provider = aws.main
}

# Policy without HTTP Basic Auth
data "aws_iam_policy_document" "web" {
  count = length(var.authentication) > 0 ? 0 : 1

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.web.arn,
      "${aws_s3_bucket.web.arn}/*",
    ]
  }

  statement {
    actions = ["cloudfront:CreateInvalidation"]

    resources = [
      aws_cloudfront_distribution.web.0.arn,
    ]
  }

  provider = aws.main
}

resource "aws_iam_user_policy" "web_basic_authentication" {
  count = length(var.authentication) > 0 ? 1 : 0

  name = "deploy-policy-${var.target_hostname}"
  user = aws_iam_user.web.id

  policy = data.aws_iam_policy_document.web_basic_authentication.0.json

  provider = aws.main
}

resource "aws_iam_user_policy" "web" {
  count = length(var.authentication) > 0 ? 0 : 1

  name = "deploy-policy-${var.target_hostname}"
  user = aws_iam_user.web.id

  policy = data.aws_iam_policy_document.web.0.json

  provider = aws.main
}

resource "aws_iam_access_key" "web" {
  user = aws_iam_user.web.name

  provider = aws.main
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "lambda" {
  count              = length(var.authentication) > 0 ? 1 : 0
  name               = "${var.name}-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}
