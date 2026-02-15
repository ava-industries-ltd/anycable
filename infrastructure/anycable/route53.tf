data "aws_route53_zone" "ava" {
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_route53_record" "anycable_alb" {
  zone_id = data.aws_route53_zone.ava.zone_id
  name    = local.anycable_subdomain
  type    = "A"

  alias {
    name                   = module.anycable.alb_dns_name
    zone_id                = module.anycable.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "grpc_alb" {
  zone_id = data.aws_route53_zone.ava.zone_id
  name    = local.grpc_subdomain
  type    = "A"

  alias {
    name                   = module.grpc.alb_dns_name
    zone_id                = module.grpc.alb_zone_id
    evaluate_target_health = true
  }
}
