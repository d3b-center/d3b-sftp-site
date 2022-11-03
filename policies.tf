data "aws_iam_policy_document" "sftp_assume_role_policy" {
  statement {

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "sftp_logging_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:GetLogEvents",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/transfer/${aws_transfer_server.sftp.id}:log-stream:*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:FilterLogEvents",
      "logs:CreateLogGroup",
    ]

    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/transfer/${aws_transfer_server.sftp.id}"
    ]
  }
}

data "aws_iam_policy_document" "sftp_transfer_server_invocation_policy" {
  statement {
    effect = "Allow"

    actions = [
      "execute-api:Invoke",
      "apigateway:GET",
    ]

    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "execute-api:Invoke",
      "lambda:InvokeFunction",
    ]

    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "s3:Put*",
      "s3:List*",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "DenyDeleteObject"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersionTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
  statement {
    sid    = "DenyDeleteBucket"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:DeleteBucket",
    ]

    resources = [
      aws_s3_bucket.bucket.arn
    ]
  }
  statement {
    sid    = "DenyUnSecureCommunications"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
      aws_s3_bucket.bucket.arn
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [false]
    }
  }
  statement {
    sid = "AllowTransferRole"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.sftp_transfer_server_invocation.arn]
    }
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
      aws_s3_bucket.bucket.arn
    ]
  }
}

data "aws_iam_policy_document" "lambda_secrets_policy" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${aws_transfer_server.sftp.id}/*"
    ]
  }
}
