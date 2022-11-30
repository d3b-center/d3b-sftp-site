resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.sftp_auth_rest_api.id

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_method_response.http_200
  ]
}

resource "aws_api_gateway_rest_api" "sftp_auth_rest_api" {
  name                         = "Transfer Family Secrets Manager Integration API"
  api_key_source               = "HEADER"
  description                  = "API used for Transfer Family to access user information in Secrets Manager"
  minimum_compression_size     = -1
  disable_execute_api_endpoint = false

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    git_commit           = "2e2eb3f6a8f0173d5bcc32de7754ce4341cbe78b"
    git_file             = "api_gateway.tf"
    git_last_modified_at = "2022-11-03 20:09:03"
    git_last_modified_by = "blackdenc@chop.edu"
    git_modifiers        = "blackdenc"
    git_org              = "d3b-center"
    git_repo             = "d3b-sftp-site"
    yor_trace            = "7c16b996-ae73-4586-a689-252b1e0c2d94"
  }
}

resource "aws_api_gateway_integration_response" "http_200" {
  http_method = "GET"
  resource_id = aws_api_gateway_resource.config.id
  rest_api_id = aws_api_gateway_rest_api.sftp_auth_rest_api.id
  status_code = "200"
  depends_on  = [aws_api_gateway_integration.integration]
}

resource "aws_api_gateway_resource" "servers" {
  parent_id   = aws_api_gateway_rest_api.sftp_auth_rest_api.root_resource_id
  path_part   = "servers"
  rest_api_id = aws_api_gateway_rest_api.sftp_auth_rest_api.id
}

resource "aws_api_gateway_resource" "serverid" {
  parent_id   = aws_api_gateway_resource.servers.id
  path_part   = "{serverId}"
  rest_api_id = aws_api_gateway_rest_api.sftp_auth_rest_api.id
}

resource "aws_api_gateway_resource" "users" {
  parent_id   = aws_api_gateway_resource.serverid.id
  path_part   = "users"
  rest_api_id = aws_api_gateway_rest_api.sftp_auth_rest_api.id
}

resource "aws_api_gateway_resource" "username" {
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "{username}"
  rest_api_id = aws_api_gateway_rest_api.sftp_auth_rest_api.id
}

resource "aws_api_gateway_resource" "config" {
  parent_id   = aws_api_gateway_resource.username.id
  path_part   = "config"
  rest_api_id = aws_api_gateway_rest_api.sftp_auth_rest_api.id
}

resource "aws_api_gateway_stage" "prod" {
  cache_cluster_enabled = false
  deployment_id         = aws_api_gateway_deployment.deployment.id
  rest_api_id           = aws_api_gateway_rest_api.sftp_auth_rest_api.id
  stage_name            = "prod"
  xray_tracing_enabled  = true
  tags = {
    git_commit           = "2e2eb3f6a8f0173d5bcc32de7754ce4341cbe78b"
    git_file             = "api_gateway.tf"
    git_last_modified_at = "2022-11-03 20:09:03"
    git_last_modified_by = "blackdenc@chop.edu"
    git_modifiers        = "blackdenc"
    git_org              = "d3b-center"
    git_repo             = "d3b-sftp-site"
    yor_trace            = "216e8f63-6bf5-4a69-9218-92abcc571962"
  }
}

resource "aws_api_gateway_model" "user_config" {
  content_type = "application/json"
  description  = "API response for GetUserConfig"
  name         = "UserConfigResponseModel"
  rest_api_id  = aws_api_gateway_rest_api.sftp_auth_rest_api.id
  depends_on   = [aws_api_gateway_rest_api.sftp_auth_rest_api]
  schema       = <<EOF
{"$schema":"http://json-schema.org/draft-04/schema#","title":"UserUserConfig","type":"object","properties":{"Role":{"type":"string"},"Policy":{"type":"string"},"HomeDirectory":{"type":"string"},"PublicKeys":{"type":"array","items":{"type":"string"}}}}
EOF
}

resource "aws_api_gateway_method" "api_gateway_method" {
  api_key_required = false
  authorization    = "AWS_IAM"
  http_method      = "GET"
  resource_id      = aws_api_gateway_resource.config.id
  rest_api_id      = aws_api_gateway_rest_api.sftp_auth_rest_api.id

  request_parameters = {
    "method.request.header.Password" = "false"
  }
}

resource "aws_api_gateway_method_response" "http_200" {
  http_method = "GET"
  resource_id = aws_api_gateway_resource.config.id
  rest_api_id = aws_api_gateway_rest_api.sftp_auth_rest_api.id
  status_code = "200"
  depends_on = [
    aws_api_gateway_model.user_config,
    aws_api_gateway_method_response.http_200
  ]

  response_models = {
    "application/json" = "UserConfigResponseModel"
  }
}

resource "aws_api_gateway_integration" "integration" {
  cache_namespace         = aws_api_gateway_resource.config.id
  connection_type         = "INTERNET"
  http_method             = aws_api_gateway_method.api_gateway_method.http_method
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  resource_id             = aws_api_gateway_resource.config.id
  rest_api_id             = aws_api_gateway_rest_api.sftp_auth_rest_api.id
  timeout_milliseconds    = "29000"
  type                    = "AWS"
  uri                     = aws_lambda_function.authentiation_lambda.invoke_arn

  request_templates = {
    "application/json" = <<EOF
{
  "username": "$util.urlDecode($input.params('username'))",
  "password": "$util.escapeJavaScript($input.params('Password')).replaceAll("\\'","'")",
  "protocol": "$input.params('protocol')",
  "serverId": "$input.params('serverId')",
  "sourceIp": "$input.params('sourceIp')"
}
EOF
  }
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.sftp_auth_rest_api.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  depends_on = [
    aws_api_gateway_method.api_gateway_method
  ]
  statement_id  = "AllowExecutionFromAPIGatewayMethod"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authentiation_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.sftp_auth_rest_api.id}/*/*/*"
}
