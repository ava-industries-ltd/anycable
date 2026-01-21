resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.environment}.internal"
  vpc         = var.vpc_id
  description = "Namespace for ${var.environment}"
}

resource "aws_service_discovery_service" "main" {
  name = var.name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }
}
