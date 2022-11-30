resource "aws_transfer_server" "sftp" {
  #checkov:skip=CKV_AWS_164:This transfer server is intended to be publically accessible
  logging_role = aws_iam_role.sftp_transfer_server.arn
  protocols    = ["SFTP"]

  identity_provider_type = "API_GATEWAY"
  invocation_role        = aws_iam_role.sftp_transfer_server_invocation.arn
  url                    = aws_api_gateway_stage.prod.invoke_url

  tags = {
    "Name"               = "D3b-SFTP"
    git_commit           = "2e2eb3f6a8f0173d5bcc32de7754ce4341cbe78b"
    git_file             = "transfer_server.tf"
    git_last_modified_at = "2022-11-03 20:09:03"
    git_last_modified_by = "blackdenc@chop.edu"
    git_modifiers        = "blackdenc"
    git_org              = "d3b-center"
    git_repo             = "d3b-sftp-site"
    yor_trace            = "e2efd52e-3b88-4312-864f-72d28b41db66"
  }
}
