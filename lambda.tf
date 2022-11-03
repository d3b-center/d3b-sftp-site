data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "authentiation_lambda" {
  function_name = "${var.application}-${var.environment}"
  description   = "A function to lookup and return user data from AWS Secrets Manager."

  filename                       = "${path.module}/lambda.zip"
  source_code_hash               = data.archive_file.lambda_zip.output_base64sha256
  reserved_concurrent_executions = 100

  handler     = var.lambda_handler
  runtime     = var.lambda_runtime
  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory
  role        = aws_iam_role.custom_lambda_authorization.arn

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      SecretsManagerRegion = var.region
    }
  }
  tags = {
    git_commit           = "67f6dc72856215c702d1198787a009f287326f30"
    git_file             = "lambda.tf"
    git_last_modified_at = "2022-11-03 20:09:03"
    git_last_modified_by = "blackdenc@chop.edu"
    git_modifiers        = "blackdenc"
    git_org              = "d3b-center"
    git_repo             = "d3b-sftp-site"
    yor_trace            = "e4cbbd49-f19d-42a4-96c1-66cc7f8da834"
  }
}
