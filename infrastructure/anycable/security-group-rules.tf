resource "aws_security_group_rule" "anycable_redis_access" {
  description              = "Anycable Redis access"
  security_group_id        = var.redis_security_group_id
  type                     = "ingress"
  from_port                = var.redis_port
  to_port                  = var.redis_port
  protocol                 = "tcp"
  source_security_group_id = module.anycable.ecs_security_group_id
}

resource "aws_security_group_rule" "anycable_redis_reader_access" {
  description              = "Anycable Serverless Valkey reader endpoint access"
  security_group_id        = var.redis_security_group_id
  type                     = "ingress"
  from_port                = 6380
  to_port                  = 6380
  protocol                 = "tcp"
  source_security_group_id = module.anycable.ecs_security_group_id
}

resource "aws_security_group_rule" "anycable_legacy_redis_access" {
  description              = "Anycable Rails cache Redis access"
  security_group_id        = var.legacy_redis_security_group_id
  type                     = "ingress"
  from_port                = var.legacy_redis_port
  to_port                  = var.legacy_redis_port
  protocol                 = "tcp"
  source_security_group_id = module.anycable.ecs_security_group_id
}

resource "aws_security_group_rule" "anycable_grpc_access" {
  description              = "Anycable gRPC access"
  security_group_id        = module.grpc.ecs_security_group_id
  type                     = "ingress"
  from_port                = var.grpc_port
  to_port                  = var.grpc_port
  protocol                 = "tcp"
  source_security_group_id = module.anycable.ecs_security_group_id
}

resource "aws_security_group_rule" "anycable_database_access" {
  description              = "gRPC Database access"
  security_group_id        = var.database_security_group
  type                     = "ingress"
  from_port                = var.postgres_port
  to_port                  = var.postgres_port
  protocol                 = "tcp"
  source_security_group_id = module.grpc.ecs_security_group_id
}

resource "aws_security_group_rule" "anycable_audit_database_access" {
  description              = "gRPC Audit Database access"
  security_group_id        = var.audit_database_security_group
  type                     = "ingress"
  from_port                = var.postgres_port
  to_port                  = var.postgres_port
  protocol                 = "tcp"
  source_security_group_id = module.grpc.ecs_security_group_id
}

resource "aws_security_group_rule" "grpc_redis_access" {
  description              = "gRPC Redis access"
  security_group_id        = var.redis_security_group_id
  type                     = "ingress"
  from_port                = var.redis_port
  to_port                  = var.redis_port
  protocol                 = "tcp"
  source_security_group_id = module.grpc.ecs_security_group_id
}

resource "aws_security_group_rule" "grpc_redis_reader_access" {
  description              = "gRPC Serverless Valkey reader endpoint access"
  security_group_id        = var.redis_security_group_id
  type                     = "ingress"
  from_port                = 6380
  to_port                  = 6380
  protocol                 = "tcp"
  source_security_group_id = module.grpc.ecs_security_group_id
}

resource "aws_security_group_rule" "grpc_legacy_redis_access" {
  description              = "gRPC Rails cache Redis access"
  security_group_id        = var.legacy_redis_security_group_id
  type                     = "ingress"
  from_port                = var.legacy_redis_port
  to_port                  = var.legacy_redis_port
  protocol                 = "tcp"
  source_security_group_id = module.grpc.ecs_security_group_id
}
