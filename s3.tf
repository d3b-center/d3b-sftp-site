resource "aws_s3_bucket" "bucket" {
  #checkov:skip=CKV_AWS_144:This bucket should not be replicated, and instead data will be processed with de-identification workflow
  bucket = var.bucket_name

  tags = {
    Name                 = var.bucket_name
    git_commit           = "67f6dc72856215c702d1198787a009f287326f30"
    git_file             = "s3.tf"
    git_last_modified_at = "2022-11-03 20:09:03"
    git_last_modified_by = "blackdenc@chop.edu"
    git_modifiers        = "blackdenc"
    git_org              = "d3b-center"
    git_repo             = "d3b-sftp-site"
    yor_trace            = "6b203d50-e4a1-42e5-9208-a77143553189"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_s3_bucket_logging" "bucket_logging" {
#   bucket = aws_s3_bucket.bucket.id

#   target_bucket = var.target_bucket
#   target_prefix = "${aws_s3_bucket.bucket.id}/"
# }

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_sse_configuration" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
