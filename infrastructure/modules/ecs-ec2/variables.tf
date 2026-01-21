variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
}

variable "name" {
  description = "Name of the service"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "ecs_subnet_ids" {
  description = "List of subnet IDs for the ECS tasks"
  type        = list(string)
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "enable_container_healthcheck" {
  description = "Turn the container‑level health check on/off."
  type        = bool
  default     = true
}

variable "health_check_command" {
  type        = list(string)
  default     = null
}

variable "health_check_start_period" {
  description = "Health check start period"
  type        = number
  default     = 10
}

variable "health_check_retries" {
  description = "Number of health check retries"
  type        = number
  default     = 2
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "cluster_name" {
  description = "ECS Cluster"
  type        = string
  default     = null
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "image_version" {
  description = "Version/tag of the container image"
  type        = string
}

variable "container_cpu" {
  description = "CPU units for the container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory limit for the container in MiB"
  type        = number
  default     = 512
}

variable "container_environment" {
  description = "Environment for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_secrets" {
  description = "Secrets for the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "resource_requirements" {
  description = "Resource requirements"
  type = list(object({
    type  = string
    value = string
  }))
  default = []
}

variable "container_command" {
  description = "Command for the container"
  type        = list(string)
  default     = []

}

variable "desired_count" {
  description = "Desired number of tasks/instances"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ecs_ami_id" {
  description = "ID of the ECS-optimized AMI"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}


######################
# variables.tf

variable "enable_ecs_autoscaling" {
  description = "Enable ECS service autoscaling"
  type        = bool
  default     = false
}

variable "ecs_autoscaling_min_capacity" {
  description = "Minimum number of ECS tasks when autoscaling is enabled"
  type        = number
  default     = 1
}

variable "ecs_autoscaling_max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 4
}

variable "scale_in_adjustment" {
  description = "Scaling adjustment for scaling in (negative number)"
  type        = number
  default     = -1
}

variable "scale_out_adjustment" {
  description = "Scaling adjustment for scaling out (positive number)"
  type        = number
  default     = 1
}

variable "scale_in_cooldown" {
  description = "Cooldown period before allowing further scale in"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown period before allowing further scale out"
  type        = number
  default     = 300
}

variable "scale_out_metric_name" {
  description = "Metric name for scaling out"
  type        = string
  default     = "CPUUtilization"
}

variable "scale_in_metric_name" {
  description = "Metric name for scaling in"
  type        = string
  default     = "CPUUtilization"
}

variable "scale_out_alarm_config" {
  description = "Configuration for the CloudWatch metric alarm for scaling out"
  type = object({
    metric_name               = string
    namespace                 = string
    comparison_operator       = string
    threshold                 = number
    evaluation_periods        = number
    period                    = number
    statistic                 = string
    dimensions                = optional(map(string))
    treat_missing_data        = optional(string)
    unit                      = optional(string)
    alarm_actions             = optional(list(string))
    insufficient_data_actions = optional(list(string))
    ok_actions                = optional(list(string))
    datapoints_to_alarm       = optional(number)
    extended_statistic        = optional(string)
  })
  default = {
    metric_name         = "CPUUtilization"
    namespace           = "AWS/ECS"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    threshold           = 80
    evaluation_periods  = 2
    period              = 300
    statistic           = "Average"
  }
}

variable "scale_in_alarm_config" {
  description = "Configuration for the CloudWatch metric alarm for scaling in"
  type = object({
    metric_name               = string
    namespace                 = string
    comparison_operator       = string
    threshold                 = number
    evaluation_periods        = number
    period                    = number
    statistic                 = string
    dimensions                = optional(map(string))
    treat_missing_data        = optional(string)
    unit                      = optional(string)
    alarm_actions             = optional(list(string))
    insufficient_data_actions = optional(list(string))
    ok_actions                = optional(list(string))
    datapoints_to_alarm       = optional(number)
    extended_statistic        = optional(string)
  })
  default = {
    metric_name         = "CPUUtilization"
    namespace           = "AWS/ECS"
    comparison_operator = "LessThanOrEqualToThreshold"
    threshold           = 30
    evaluation_periods  = 2
    period              = 300
    statistic           = "Average"
  }
}
