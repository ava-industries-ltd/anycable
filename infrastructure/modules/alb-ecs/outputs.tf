output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_arn_suffix" {
  description = "The ARN suffix of the ALB (for CloudWatch dimensions)"
  value       = aws_lb.main.arn_suffix
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "target_group_arn_suffix" {
  description = "The ARN suffix of the ALB target group (for CloudWatch dimensions)"
  value       = aws_lb_target_group.main.arn_suffix
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = local.cluster_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = local.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = local.ecs_service.name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.main.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.name
}

output "ecs_security_group_id" {
    description = "ECS Task security group"
    value = aws_security_group.ecs_tasks.id
}

output "alb_security_group_id" {
    description = "ECS Task security group"
    value = aws_security_group.alb.id
}

output "task_role_name" {
    description = "ECS Task role name"
    value = aws_iam_role.task.name
}

output "task_role_arn" {
    description = "ECS Task role ARN"
    value = aws_iam_role.task.arn
}

output "task_execution_role_name" {
    description = "ECS Task Execution role name"
    value = aws_iam_role.task_execution.name
}

output "task_execution_role_arn" {
    description = "ECS Task Execution role ARN"
    value = aws_iam_role.task_execution.arn
}
