output "app_instance_id" {
  value = aws_instance.app_instance.id
}

output "app_ami_id" {
  value = aws_ami_from_instance.app_ami.id
}

output "app_alb_dns_name" {
  value = aws_lb.internal_alb.dns_name
}

output "app_asg_name" {
  value = aws_autoscaling_group.app_asg.name
}