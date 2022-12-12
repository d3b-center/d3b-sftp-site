data "aws_route53_zone" "public_zone" {
  name = var.domain_name
}

data "aws_route53_zone" "private_zone" {
  name         = var.domain_name
  private_zone = true
}

resource "aws_transfer_tag" "sftp_hosted_zone_tag" {
  resource_arn = aws_transfer_server.sftp.arn
  key          = "aws:transfer:route53HostedZoneId"
  value        = "/hostedzone/${data.aws_route53_zone.public_zone.zone_id}"
}

resource "aws_transfer_tag" "sftp_custom_hostname_tag" {
  resource_arn = aws_transfer_server.sftp.arn
  key          = "aws:transfer:customHostname"
  value        = local.custom_hostname
}

resource "aws_route53_record" "public_sftp" {
  zone_id = data.aws_route53_zone.public_zone.zone_id
  name    = local.custom_hostname
  type    = "CNAME"
  ttl     = "300"
  records = [aws_transfer_server.sftp.endpoint]

  depends_on = [aws_transfer_server.sftp]
}

resource "aws_route53_record" "private_sftp" {
  zone_id = data.aws_route53_zone.private_zone.zone_id
  name    = local.custom_hostname
  type    = "CNAME"
  ttl     = "300"
  records = [aws_transfer_server.sftp.endpoint]

  depends_on = [aws_transfer_server.sftp]
}
