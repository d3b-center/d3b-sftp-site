resource "aws_iam_role" "sftp_transfer_server" {
  name               = "${var.org}-sftp-${var.application}-role"
  assume_role_policy = data.aws_iam_policy_document.sftp_assume_role_policy.json
  tags = {
    git_commit           = "2e2eb3f6a8f0173d5bcc32de7754ce4341cbe78b"
    git_file             = "iam.tf"
    git_last_modified_at = "2022-11-03 20:09:03"
    git_last_modified_by = "blackdenc@chop.edu"
    git_modifiers        = "blackdenc"
    git_org              = "d3b-center"
    git_repo             = "d3b-sftp-site"
    yor_trace            = "df844783-299e-4704-9228-19365479172d"
    yor_name             = "sftp_transfer_server"
  }
}

resource "aws_iam_role_policy" "sftp_transfer_server" {
  name   = "${var.org}-sftp-${var.application}-policy"
  role   = aws_iam_role.sftp_transfer_server.id
  policy = data.aws_iam_policy_document.sftp_logging_policy.json
}

resource "aws_iam_role" "sftp_transfer_server_invocation" {
  name               = "${var.org}-sftp-${var.application}-invocation-role"
  assume_role_policy = data.aws_iam_policy_document.sftp_assume_role_policy.json
  tags = {
    git_commit           = "2e2eb3f6a8f0173d5bcc32de7754ce4341cbe78b"
    git_file             = "iam.tf"
    git_last_modified_at = "2022-11-03 20:09:03"
    git_last_modified_by = "blackdenc@chop.edu"
    git_modifiers        = "blackdenc"
    git_org              = "d3b-center"
    git_repo             = "d3b-sftp-site"
    yor_trace            = "8890500e-968d-4f49-b089-e26db805396e"
    yor_name             = "sftp_transfer_server_invocation"
  }
}

resource "aws_iam_role_policy" "sftp_transfer_server_invocation" {
  name   = "${var.org}-sftp-${var.application}-invocation-policy"
  role   = aws_iam_role.sftp_transfer_server_invocation.id
  policy = data.aws_iam_policy_document.sftp_transfer_server_invocation_policy.json
}

resource "aws_iam_role" "custom_lambda_authorization" {
  name               = "${var.org}-${var.application}-authorizaion-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  tags = {
    git_commit           = "2e2eb3f6a8f0173d5bcc32de7754ce4341cbe78b"
    git_file             = "iam.tf"
    git_last_modified_at = "2022-11-03 20:09:03"
    git_last_modified_by = "blackdenc@chop.edu"
    git_modifiers        = "blackdenc"
    git_org              = "d3b-center"
    git_repo             = "d3b-sftp-site"
    yor_trace            = "556c7180-a664-4a75-8935-91532022357e"
    yor_name             = "custom_lambda_authorization"
  }
}

resource "aws_iam_role_policy" "custom_lambda_secrets_policy" {
  name   = "${var.org}-${var.application}-authorization-secrets-policy"
  role   = aws_iam_role.custom_lambda_authorization.id
  policy = data.aws_iam_policy_document.lambda_secrets_policy.json
}

resource "aws_iam_role_policy_attachment" "custom_lambda_execution_policy" {
  role       = aws_iam_role.custom_lambda_authorization.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
