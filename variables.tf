variable "region" {
  description = "Region for the bucket"
  default     = "us-east-1"
}

variable "environment" {
  description = "dev,qa,prd,service"
  type        = string
  default     = "prd"
}

variable "description" {
  description = "Tag description for the bucket"
  default     = "Bucket for SFTP Transfer"
}

variable "bucket_name" {
  description = "Bucket name"
}

variable "target_bucket" {
  description = "Target bucket for logging"
  default     = ""
}

variable "object_ownership" {
  default     = "BucketOwnerEnforced"
  description = "Object Ownership rules. Replaces ACLs"
  type        = string
}

variable "lambda_runtime" {
  default = "python3.9"
}

variable "lambda_timeout" {
  default = "60"
}

variable "lambda_memory" {
  default = "256"
}

variable "lambda_handler" {
  default = "index.lambda_handler"
}

variable "org" {
  default = "d3b"
}

variable "domain_name" {
  type        = string
  description = "Domain name for SFTP Route53 endpoint"
}

variable "sftp_users" {
  type        = map(map(string))
  description = "Map of user information"
  default = {
    test_user = {
      Password   = "MySuperSecretPassword"
      BucketPath = "chop/test_user"
    }
  }
}

variable "application" {
  default = "sftp-auth-lambda"
}

variable "sftp_host" {
  description = "Prefix for the custom hostname for the SFTP server"
  default     = "sftp"
  type        = string
}
