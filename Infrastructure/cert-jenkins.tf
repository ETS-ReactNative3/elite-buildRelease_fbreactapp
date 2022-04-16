//* Certificate *//

resource "aws_acm_certificate" "jenkinscert" {
  domain_name       = "*.elitelabtools.com"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.common_tags,
    { Name = "jenkinsdev.elitelabtools.com"
  Cert = "jenkinscert" })
}

resource "aws_route53_record" "jenkinszone_record" {
  for_each = {
    for dvo in aws_acm_certificate.jenkinscert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main-zone.zone_id
}

resource "aws_acm_certificate_validation" "jenkinscert" {
  certificate_arn         = aws_acm_certificate.jenkinscert.arn
  validation_record_fqdns = [for record in aws_route53_record.jenkinszone_record : record.fqdn]
}

##------- ALB Alias record ----------##
resource "aws_route53_record" "www_jenkins" {
  zone_id = data.aws_route53_zone.main-zone.zone_id
  name    = "jenkinsdev.elitelabtools.com"
  type    = "A"

  alias {
    name                   = aws_lb.jenkinslb.dns_name
    zone_id                = aws_lb.jenkinslb.zone_id
    evaluate_target_health = true
  }
}