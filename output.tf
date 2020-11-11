locals {
  cloudfront_id = flatten(concat(
    aws_cloudfront_distribution.web.*.id,
    aws_cloudfront_distribution.web_basic_authentication.*.id,
  ))
}

output "web_deploy_access_key" {
  value = aws_iam_access_key.web.id
}

output "web_deploy_secret_key" {
  value = aws_iam_access_key.web.secret
}

output "web_cloudfront_id" {
  value = length(local.cloudfront_id) == 0 ? "" : local.cloudfront_id[0]
}
