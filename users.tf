resource "aws_secretsmanager_secret" "user" {
  for_each = var.sftp_users
  name     = "${aws_transfer_server.sftp.id}/${each.key}"
  tags = {
    git_commit           = "67f6dc72856215c702d1198787a009f287326f30"
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
