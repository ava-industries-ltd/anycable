data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

data "aws_ecs_cluster" "existing" {
  count        = var.cluster_name == null ? 0 : 1
  cluster_name = var.cluster_name
}

locals {
  account_id   = data.aws_caller_identity.current.account_id
  cluster_id   = var.cluster_name == null ? aws_ecs_cluster.main[0].id : data.aws_ecs_cluster.existing[0].id
  cluster_name = var.cluster_name == null ? aws_ecs_cluster.main[0].name : var.cluster_name
  ecs_service  = length(aws_ecs_service.manual) > 0 ? aws_ecs_service.manual[0] : aws_ecs_service.autoscaled[0]
  default_dimensions = {
    ClusterName = local.cluster_name
    ServiceName = local.ecs_service.name
  }

  healthcheck =  var.health_check_command == null ? null : {
    command     = var.health_check_command    
    interval    = var.health_check_interval
    timeout     = var.health_check_timeout
    retries     = var.health_check_retries
    startPeriod = var.health_check_start_period
  }
}
