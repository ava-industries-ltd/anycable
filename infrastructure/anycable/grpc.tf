module "grpc" {
  source = "../modules/ecs-ec2"

  environment            = var.environment
  name                   = local.grpc_name
  vpc_id                 = var.vpc_id
  ecs_subnet_ids         = local.private_subnet_ids
  ecr_repository_url     = var.ava_emr_image
  image_version          = var.ava_emr_version
  ecs_ami_id             = "ami-05ab4ffc97771c4ae" # /aws/service/ecs/optimized-ami/amazon-linux-2023/recommended
  instance_type          = var.grpc_instance_type
  desired_count          = var.grpc_desired_count
  container_cpu          = var.grpc_cpu
  container_memory       = var.grpc_memory
  container_environment  = local.grpc_container_environment_variables
  container_secrets      = local.grpc_container_secrets
  container_command      = local.grpc_container_command
  container_port         = var.grpc_port
  health_check_command   = ["CMD-SHELL", "curl -sf http://localhost:${var.grpc_health_port}${var.grpc_health_path} || exit 1"]
  enable_ecs_autoscaling = false

  tags = {
    Environment = var.environment
    Service     = local.grpc_name
  }
}
