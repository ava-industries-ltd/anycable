# resource "aws_ssm_parameter" "anycable_rpc_host" {
#   name        = "/ava/${var.environment}/config/anycable/rpc_host"
#   description = "EMR task role name for ${var.name}-${var.environment}"
#   type        = "String"
#   value       = module.grpc.ecs_service_dns
# }
