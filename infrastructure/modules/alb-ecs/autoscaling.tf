resource "aws_appautoscaling_target" "ecs_service" {
  count = var.enable_ecs_autoscaling ? 1 : 0

  max_capacity       = var.ecs_autoscaling_max_capacity
  min_capacity       = var.ecs_autoscaling_min_capacity
  resource_id        = "service/${local.cluster_name}/${local.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_scale_out" {
  count = var.enable_ecs_autoscaling ? 1 : 0

  name               = "${var.name}-scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_out_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      scaling_adjustment          = var.scale_out_adjustment
      metric_interval_lower_bound = 0
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_scale_in" {
  count = var.enable_ecs_autoscaling ? 1 : 0

  name               = "${var.name}-scale-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_in_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      scaling_adjustment          = var.scale_in_adjustment
      metric_interval_upper_bound = 0
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  count = var.enable_ecs_autoscaling ? 1 : 0

  alarm_name          = "${var.name}-scale-out"
  metric_name         = var.scale_out_alarm_config.metric_name
  namespace           = var.scale_out_alarm_config.namespace
  comparison_operator = var.scale_out_alarm_config.comparison_operator
  threshold           = var.scale_out_alarm_config.threshold
  evaluation_periods  = var.scale_out_alarm_config.evaluation_periods
  period              = var.scale_out_alarm_config.period
  statistic           = var.scale_out_alarm_config.statistic

  alarm_actions = [aws_appautoscaling_policy.ecs_scale_out[0].arn]

  dimensions = try(length(var.scale_out_alarm_config.dimensions) > 0 ? var.scale_out_alarm_config.dimensions : local.default_dimensions, local.default_dimensions)

  treat_missing_data  = lookup(var.scale_out_alarm_config, "treat_missing_data", null)
  unit                = lookup(var.scale_out_alarm_config, "unit", null)
  datapoints_to_alarm = lookup(var.scale_out_alarm_config, "datapoints_to_alarm", null)
  extended_statistic  = lookup(var.scale_out_alarm_config, "extended_statistic", null)
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  count = var.enable_ecs_autoscaling ? 1 : 0

  alarm_name          = "${var.name}-scale-in"
  metric_name         = var.scale_in_alarm_config.metric_name
  namespace           = var.scale_in_alarm_config.namespace
  comparison_operator = var.scale_in_alarm_config.comparison_operator
  threshold           = var.scale_in_alarm_config.threshold
  evaluation_periods  = var.scale_in_alarm_config.evaluation_periods
  period              = var.scale_in_alarm_config.period
  statistic           = var.scale_in_alarm_config.statistic

  alarm_actions = [aws_appautoscaling_policy.ecs_scale_in[0].arn]

  dimensions = try(length(var.scale_in_alarm_config.dimensions) > 0 ? var.scale_in_alarm_config.dimensions : local.default_dimensions, local.default_dimensions)

  treat_missing_data  = lookup(var.scale_in_alarm_config, "treat_missing_data", null)
  unit                = lookup(var.scale_in_alarm_config, "unit", null)
  datapoints_to_alarm = lookup(var.scale_in_alarm_config, "datapoints_to_alarm", null)
  extended_statistic  = lookup(var.scale_in_alarm_config, "extended_statistic", null)
}