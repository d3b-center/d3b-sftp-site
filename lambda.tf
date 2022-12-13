data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "authentiation_lambda" {
  #checkov:skip=CKV_AWS_272:No definition for this rule
  #checkov:skip=CKV_AWS_117:This function is intended for public-facing use by authorized users
  #checkov:skip=CKV_AWS_116:TODO-Add dead-letter queue
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
    git_commit           = "2e2eb3f6a8f0173d5bcc32de7754ce4341cbe78b"
    git_file             = "lambda.tf"
    git_last_modified_at = "2022-11-03 20:09:03"
    git_last_modified_by = "blackdenc@chop.edu"
    git_modifiers        = "blackdenc"
    git_org              = "d3b-center"
    git_repo             = "d3b-sftp-site"
    yor_trace            = "e4cbbd49-f19d-42a4-96c1-66cc7f8da834"
  }
}
