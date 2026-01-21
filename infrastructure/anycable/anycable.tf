module "anycable" {
  source = "../modules/alb-ecs"

  environment                      = var.environment
  name                             = local.anycable_name
  vpc_id                           = var.vpc_id
  ecs_subnet_ids                   = local.private_subnet_ids
  alb_subnet_ids                   = local.public_subnet_ids
  ecr_repository_url               = var.ava_anycable_image
  image_version                    = var.anycable_go_version
  ecs_ami_id                       = "ami-0f3f945b57ae3ec8f" # /aws/service/ecs/optimized-ami/amazon-linux-2023/arm64/recommended/image_id
  instance_type                    = var.anycable_instance_type
  desired_count                    = var.anycable_desired_count
  acm_certificate_arn              = data.aws_acm_certificate.physician.arn
  container_cpu                    = var.anycable_cpu
  container_memory                 = var.anycable_memory
  container_environment            = local.anycable_container_environment_variables
  container_secrets                = local.anycable_container_secrets
  container_command                = local.anycable_container_command
  health_check_healthy_threshold   = var.anycable_health_check_healthy_threshold
  health_check_unhealthy_threshold = var.anycable_health_check_unhealthy_threshold
  health_check_timeout             = var.anycable_health_check_timeout
  health_check_interval            = var.anycable_health_check_interval
  health_check_path                = var.anycable_health_check_path
  health_check_matcher             = var.anycable_health_check_matcher

  # Enable ECS autoscaling
  enable_ecs_autoscaling = false

  alb_logging_bucket = "${var.name}-${var.environment}-${var.region}-logs"

  tags = {
    Environment = var.environment
    Service     = local.anycable_name
  }
}
