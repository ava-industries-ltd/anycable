resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.enable_http_redirect_listener && (length(var.allowed_cidr_blocks) > 0 || length(var.allowed_ipv6_cidr_blocks) > 0) ? [80] : []
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = var.allowed_cidr_blocks
      ipv6_cidr_blocks = var.allowed_ipv6_cidr_blocks
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 || length(var.allowed_ipv6_cidr_blocks) > 0 ? [var.listener_port] : []
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = var.allowed_cidr_blocks
      ipv6_cidr_blocks = var.allowed_ipv6_cidr_blocks
    }
  }

  dynamic "ingress" {
    for_each = toset(var.alb_ingress_security_group_ids)
    content {
      from_port       = var.listener_port
      to_port         = var.listener_port
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "main" {
  name               = "${var.name}-alb"
  internal           = var.internal_alb
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.alb_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = var.alb_idle_timeout
  #   drop_invalid_header_fields = true

  access_logs {
    bucket  = local.alb_logging_bucket
    enabled = var.alb_logging_enabled
    prefix  = var.alb_logging_prefix
  }

  tags = var.tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "http" {
  count             = var.enable_http_redirect_listener ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# ALB Target Group
resource "aws_lb_target_group" "main" {
  name             = var.target_group_name_prefix == null ? "${var.name}-target-group" : null
  name_prefix      = var.target_group_name_prefix
  port             = var.container_port
  vpc_id           = var.vpc_id
  target_type      = "ip"
  protocol         = var.target_group_protocol
  protocol_version = var.target_group_protocol_version

  health_check {
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    matcher             = var.health_check_matcher
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafv2_web_acl_association" "main" {
  count        = (var.web_acl_arn == "") ? 0 : 1
  resource_arn = aws_lb.main.arn
  web_acl_arn  = var.web_acl_arn
}

###########################

resource "aws_s3_bucket" "alb_logs" {
  count  = var.alb_logging_enabled && var.alb_logging_bucket == null ? 1 : 0
  bucket = "${var.name}-logs"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "${var.name}-logs"
    Description = ""
    Security    = "SSE:AWS"
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  count  = var.alb_logging_enabled && var.alb_logging_bucket == null ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    id     = "log"
    status = "Enabled"

    filter { prefix = "" }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  count  = var.alb_logging_enabled && var.alb_logging_bucket == null ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  count  = var.alb_logging_enabled && var.alb_logging_bucket == null ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  count  = var.alb_logging_enabled && var.alb_logging_bucket == null ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "alb_logs" {
  count     = var.alb_logging_enabled && var.alb_logging_bucket == null ? 1 : 0
  policy_id = "${aws_s3_bucket.alb_logs[0].id}-policy"
  statement {
    sid     = "AllowSSLRequestsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.alb_logs[0].arn,
      "${aws_s3_bucket.alb_logs[0].arn}/*"
    ]
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
    principals {
      identifiers = ["*"]
      type        = "*"
    }
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  count      = var.alb_logging_enabled && var.alb_logging_bucket == null ? 1 : 0
  bucket     = aws_s3_bucket.alb_logs[0].id
  policy     = data.aws_iam_policy_document.alb_logs[0].json
  depends_on = [aws_s3_bucket_public_access_block.alb_logs[0]]
}
