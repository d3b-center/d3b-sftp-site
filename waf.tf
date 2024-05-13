resource "aws_wafv2_web_acl_association" "example_acl_association" {
  resource_arn = aws_api_gateway_stage.prod.arn
  web_acl_arn  = data.aws_wafv2_web_acl.web_acl_default.arn
}

data "aws_wafv2_web_acl" "web_acl_default" {
  name  = "${var.org}-apps-web-acl-${var.environment}"
  scope = "REGIONAL"
}