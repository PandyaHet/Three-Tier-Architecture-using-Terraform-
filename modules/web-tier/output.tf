output "web_instance_id" {
  value = aws_instance.web_instance.id
}

output "web_instance_public_ip" {
  value = aws_instance.web_instance.public_ip
}

output "web_alb_dns_name" {
  value = aws_lb.public_alb.dns_name
}

output "web_asg_name" {
  value = aws_autoscaling_group.web_asg.name
}

output "web_target_group_arn" {
  value = aws_lb_target_group.web_tg.arn
}