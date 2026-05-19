resource "aws_cloudwatch_metric_alarm" "alb_latency" {
  count = var.enable_alb_monitoring_alarms ? 1 : 0

  alarm_name        = "${var.name}-alb-target-response-time-high"
  alarm_description = "${var.name}-alb target response time is high."
  namespace         = "AWS/ApplicationELB"
  metric_name       = "TargetResponseTime"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.alb_latency_threshold_seconds
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alb_alarm_actions
  ok_actions          = var.alb_ok_actions

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_elb_5xx" {
  count = var.enable_alb_monitoring_alarms ? 1 : 0

  alarm_name        = "${var.name}-alb-elb-5xx-count-high"
  alarm_description = "${var.name}-alb generated 5XX responses."
  namespace         = "AWS/ApplicationELB"
  metric_name       = "HTTPCode_ELB_5XX_Count"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.alb_5xx_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alb_alarm_actions
  ok_actions          = var.alb_ok_actions

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  count = var.enable_alb_monitoring_alarms ? 1 : 0

  alarm_name        = "${var.name}-alb-target-5xx-count-high"
  alarm_description = "${var.name}-alb targets generated 5XX responses."
  namespace         = "AWS/ApplicationELB"
  metric_name       = "HTTPCode_Target_5XX_Count"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.main.arn_suffix
  }

  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.alb_5xx_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alb_alarm_actions
  ok_actions          = var.alb_ok_actions

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  count = var.enable_alb_monitoring_alarms ? 1 : 0

  alarm_name        = "${var.name}-alb-unhealthy-host-count"
  alarm_description = "${var.name}-alb has unhealthy targets."
  namespace         = "AWS/ApplicationELB"
  metric_name       = "UnHealthyHostCount"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.main.arn_suffix
  }

  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alb_alarm_actions
  ok_actions          = var.alb_ok_actions

  tags = var.tags
}
