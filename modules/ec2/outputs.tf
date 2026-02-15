output "alb_dns_name" { value = aws_lb.app.dns_name }
output "alb_arn" { value = aws_lb.app.arn }
output "asg_name" { value = aws_autoscaling_group.app.name }
output "ec2_security_group_id" { value = aws_security_group.ec2.id }
output "target_group_arn" { value = aws_lb_target_group.app.arn }
output "scale_out_policy_arn" { value = aws_autoscaling_policy.scale_out.arn }
output "scale_in_policy_arn" { value = aws_autoscaling_policy.scale_in.arn }
