//* Certificate *//
#####------ Certificate -----------####
resource "aws_acm_certificate" "fbreactappcert" {
  domain_name       = "*.elitelabtools.com"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.common_tags,
    { Name = "fbreactappdev.elitelabtools.com"
  Cert = "fbreactappcert" })
}

###------- Cert Validation -------###
data "aws_route53_zone" "main-zone" {
  name         = "elitelabtools.com"
  private_zone = false
}

resource "aws_route53_record" "fbreactappzone_record" {
  for_each = {
    for dvo in aws_acm_certificate.fbreactappcert.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "fbreactappcert" {
  certificate_arn         = aws_acm_certificate.fbreactappcert.arn
  validation_record_fqdns = [for record in aws_route53_record.fbreactappzone_record : record.fqdn]
}

##------- ALB Alias record ----------##
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main-zone.zone_id
  name    = "fbreactappdev.elitelabtools.com"
  type    = "A"

  alias {
    name                   = aws_lb.fbreactapplb.dns_name
    zone_id                = aws_lb.fbreactapplb.zone_id
    evaluate_target_health = true
  }
}