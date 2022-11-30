resource "aws_secretsmanager_secret" "user" {
  for_each = var.sftp_users
  name     = "${aws_transfer_server.sftp.id}/${each.key}"
  tags = {
    git_commit           = "2e2eb3f6a8f0173d5bcc32de7754ce4341cbe78b"
    git_file             = "users.tf"
    git_last_modified_at = "2022-11-03 20:09:03"
    git_last_modified_by = "blackdenc@chop.edu"
    git_modifiers        = "blackdenc"
    git_org              = "d3b-center"
    git_repo             = "d3b-sftp-site"
    yor_trace            = "58b8ba4d-f4cc-4c89-91fe-80c273273cc2"
  }
}

resource "aws_secretsmanager_secret_version" "user_data" {
  for_each  = var.sftp_users
  secret_id = aws_secretsmanager_secret.user[each.key].id
  secret_string = jsonencode({
    "Password" : "${each.value["Password"]}", "HomeDirectoryDetails" : "[{\"Entry\": \"/\", \"Target\": \"/${aws_s3_bucket.bucket.id}/${each.value["BucketPath"]}\"}]", "Role" : "${aws_iam_role.sftp_transfer_server_invocation.arn}"
  })
}
