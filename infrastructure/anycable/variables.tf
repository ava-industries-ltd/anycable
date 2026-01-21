
variable "name" {
  type = string
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "profile" {
  type        = string
  description = "AWS Profile"
  default     = null
}

# Terraform variables

variable "physician_domain" {
  type = string
}

# variable "web_acl_arn" {
#   type    = string
#   default = ""
# }

variable "vpc_id" {
  type        = string
  description = "VPC Id"
}

variable "vpc_private_subnets" {
  type        = string
  description = "Private Subnets"
}

variable "vpc_public_subnets" {
  type        = string
  description = "Public Subnets"
}

variable "master_account_id" {
  type = string
}

variable "grpc_cpu" {
  type    = number
  default = 4096
}

variable "grpc_port" {
  type    = number
  default = 50051
}


variable "grpc_memory" {
  type    = number
  default = 15750
}

variable "anycable_cpu" {
  type    = number
  default = 4096
}

variable "anycable_memory" {
  type    = number
  default = 15750
}

variable "rails_env" {
  type = string
}

variable "redis_endpoint" {
  type = string
}

variable "redis_port" {
  type = number
}

variable "ava_anycable_image" {
  type    = string
  default = "250012284601.dkr.ecr.ca-central-1.amazonaws.com/anycable-go"
}

variable "anycable_go_version" {
  type = string
}

variable "postgres_endpoint" {
  type = string
}

variable "postgres_reader_endpoint" {
  type = string
}

variable "postgres_database" {
  type = string
}

variable "postgres_reader_database" {
  type = string
}

variable "postgres_port" {
  type = number
}

variable "postgres_reader_port" {
  type = number
}

variable "database_security_group" {
  type = string
}

variable "audit_database_security_group" {
  type = string
}

variable "audit_replica_database" {
  type = string
}

variable "audit_replica_endpoint" {
  type = string
}

variable "audit_replica_port" {
  type = number
}

variable "tags" {
  type = map(string)
}

variable "redis_security_group_id" {
  type = string
}

###################

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection on the ALB"
  type        = bool
  default     = false
}

variable "anycable_health_check_path" {
  description = "Path for ALB health checks"
  type        = string
  default     = "/health"
}

variable "anycable_health_check_healthy_threshold" {
  description = "Number of consecutive health check successes required"
  type        = number
  default     = 3
}

variable "anycable_health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required"
  type        = number
  default     = 2
}

variable "anycable_health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "anycable_health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "anycable_health_check_matcher" {
  description = "HTTP response codes to consider as healthy"
  type        = string
  default     = "200-399"
}

variable "grpc_health_check_path" {
  description = "Path for ALB health checks"
  type        = string
  default     = "/grpc.health.v1.Health/Check"
}

variable "grpc_health_check_healthy_threshold" {
  description = "Number of consecutive health check successes required"
  type        = number
  default     = 3
}

variable "grpc_health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required"
  type        = number
  default     = 2
}

variable "grpc_health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "grpc_health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "grpc_health_check_matcher" {
  description = "HTTP response codes to consider as healthy"
  type        = string
  default     = "0"
}

variable "anycable_desired_count" {
  description = "Desired number of tasks/instances for Anycable"
  type        = number
  default     = 1
}

variable "grpc_desired_count" {
  description = "Desired number of tasks/instances for gRPC"
  type        = number
  default     = 1
}

variable "anycable_instance_type" {
  description = "EC2 instance type for Anycable"
  type        = string
  default     = "t4g.xlarge"
}

variable "grpc_instance_type" {
  description = "EC2 instance type for gRPC"
  type        = string
  default     = "t3.xlarge"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 365
}

variable "ava_emr_image" {
  type = string
}

variable "ava_emr_version" {
  type = string
}

variable "grpc_health_path" {
  type    = string
  default = "/health"
}

variable "grpc_health_port" {
  type    = number
  default = 54321
}
