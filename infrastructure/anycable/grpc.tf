module "grpc" {
  source = "../modules/alb-ecs"

  environment                      = var.environment
  name                             = local.grpc_name
  vpc_id                           = var.vpc_id
  ecs_subnet_ids                   = local.private_subnet_ids
  alb_subnet_ids                   = local.private_subnet_ids
  ecr_repository_url               = var.ava_emr_image
  image_version                    = var.ava_emr_version
  ecs_ami_id                       = "ami-0fceb4a96619fcf41" # /aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id
  instance_type                    = var.grpc_instance_type
  desired_count                    = var.grpc_desired_count
  acm_certificate_arn              = var.regional_certificate_arn
  container_cpu                    = var.grpc_cpu
  container_memory                 = var.grpc_memory
  container_environment            = local.grpc_container_environment_variables
  container_secrets                = local.grpc_container_secrets
  container_command                = local.grpc_container_command
  health_check_healthy_threshold   = var.grpc_health_check_healthy_threshold
  health_check_unhealthy_threshold = var.grpc_health_check_unhealthy_threshold
  health_check_timeout             = var.grpc_health_check_timeout
  health_check_interval            = var.grpc_health_check_interval
  health_check_path                = var.grpc_health_check_path
  health_check_matcher             = var.grpc_health_check_matcher
  listener_port                    = 50051
  enable_http_redirect_listener    = false
  internal_alb                     = true
  container_port                   = 50051
  target_group_protocol            = "HTTPS"
  target_group_protocol_version    = "GRPC"
  allowed_cidr_blocks              = []
  allowed_ipv6_cidr_blocks         = []
  alb_ingress_security_group_ids   = [module.anycable.ecs_security_group_id]
  enable_ecs_autoscaling           = false
  alb_logging_bucket               = "${var.name}-${var.environment}-${var.region}-logs"

  tags = {
    Environment = var.environment
    Service     = local.grpc_name
  }
}
