data "template_file" "basicauth" {
  count    = length(var.authentication) > 0 ? 1 : 0
  template = "${file("${path.module}/lambda-scripts/basicauth.js")}"

  vars = {
    authentication = "${jsonencode(var.authentication)}"
  }
}

data "archive_file" "basicauth" {
  count       = length(var.authentication) > 0 ? 1 : 0
  type        = "zip"
  output_path = "./files/lambda/${var.name}-basicauth.zip"

  source {
    content  = "${data.template_file.basicauth.0.rendered}"
    filename = "index.js"
  }
}

resource "aws_lambda_function" "basicauth" {
  count            = length(var.authentication) > 0 ? 1 : 0
  provider         = aws.virginia
  filename         = data.archive_file.basicauth.0.output_path
  function_name    = "${var.name}-basicauth"
  role             = aws_iam_role.lambda.0.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.basicauth.0.output_base64sha256
  runtime          = "nodejs12.x"
  publish          = true
}
