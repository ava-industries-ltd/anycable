data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

data "aws_ecs_cluster" "existing" {
  count        = var.cluster_name == null ? 0 : 1
  cluster_name = var.cluster_name
}

locals {
  account_id                 = data.aws_caller_identity.current.account_id
  cluster_id                 = var.cluster_name == null ? aws_ecs_cluster.main[0].id : data.aws_ecs_cluster.existing[0].id
  cluster_name               = var.cluster_name == null ? aws_ecs_cluster.main[0].name : var.cluster_name
  ecs_service                = length(aws_ecs_service.manual) > 0 ? aws_ecs_service.manual[0] : aws_ecs_service.autoscaled[0]
  alb_listener_port          = var.use_grpc ? var.container_port : 443
  health_check_port_is_set   = can(tonumber(var.health_check_port))
  health_check_port_number   = local.health_check_port_is_set ? tonumber(var.health_check_port) : var.container_port
  has_dedicated_health_check = local.health_check_port_is_set && local.health_check_port_number != var.container_port
  default_dimensions = {
    ClusterName = local.cluster_name
    ServiceName = local.ecs_service.name
  }
  alb_logging_bucket = var.alb_logging_bucket == null ? aws_s3_bucket.alb_logs[0].id : var.alb_logging_bucket
}
