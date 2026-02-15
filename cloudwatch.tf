# ==============================================================================
# CloudWatch Alarms + SNS — CPU, ALB 5xx errors, RDS connections
# ==============================================================================

# ── SNS Topic for alerts ──────────────────────────────────────────────────────
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ── CloudWatch Alarm: High CPU on ASG ─────────────────────────────────────────
 resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "CPU utilisation exceeded 70% — triggering scale-out"
  alarm_actions       = [aws_sns_topic.alerts.arn, module.ec2.scale_out_policy_arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = module.ec2.asg_name
  }
}

# ── CloudWatch Alarm: Low CPU (scale in) ──────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "CPU utilisation below 20% — triggering scale-in"
  alarm_actions       = [module.ec2.scale_in_policy_arn]

  dimensions = {
    AutoScalingGroupName = module.ec2.asg_name
  }
}

# ── CloudWatch Alarm: ALB 5xx Errors ─────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB is returning 5xx errors — investigate immediately"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = module.ec2.alb_arn
  }
}

# ── CloudWatch Dashboard ──────────────────────────────────────────────────────
/*
 resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "EC2 CPU Utilisation"
          period = 60
          stat   = "Average"
          metrics = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", module.ec2.asg_name]]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ALB Request Count"
          period = 60
          stat   = "Sum"
          metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", module.ec2.alb_arn]]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ALB 5XX Errors"
          period = 60
          stat   = "Sum"
          metrics = [["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", module.ec2.alb_arn]]
        }
      }
    ]
  })
}*/

