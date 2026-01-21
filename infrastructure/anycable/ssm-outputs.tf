# resource "aws_ssm_parameter" "emr_task_role_arn" {
#   name        = "/ava/${var.environment}/config/emr/emr_task_role_arn"
#   description = "EMR task role ARN for ${var.name}-${var.environment}"
#   type        = "String"
#   value       = module.emr.task_role_arn
# }

# resource "aws_ssm_parameter" "emr_task_role_name" {
#   name        = "/ava/${var.environment}/config/emr/emr_task_role_name"
#   description = "EMR task role name for ${var.name}-${var.environment}"
#   type        = "String"
#   value       = module.emr.task_role_name
# }


resource "aws_ssm_parameter" "anycable_rpc_host" {
  name        = "/ava/${var.environment}/config/anycable/rpc_host"
  description = "EMR task role name for ${var.name}-${var.environment}"
  type        = "String"
  value       = module.grpc.ecs_service_dns
}
