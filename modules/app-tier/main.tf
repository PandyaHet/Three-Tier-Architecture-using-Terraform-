data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = false

  tags = {
    Name = "App-Tier-Instance"
    Tier = "App"
  }
}

resource "aws_ami_from_instance" "app_ami" {
  name               = "app-tier-ami"
  description        = "AMI created from App Tier EC2 instance"
  source_instance_id = aws_instance.app_instance.id

  tags = {
    Name = "AppTierAMI"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "app-tier-tg"
  port        = 4000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "4000"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "AppTierTargetGroup"
  }
}

resource "aws_lb" "internal_alb" {
  name               = "private-app-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.internal_elb_sg_id]
  subnets            = var.subnet_ids

  tags = {
    Name = "InternalAppALB"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-tier-template-"
  image_id      = aws_ami_from_instance.app_ami.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  vpc_security_group_ids = [var.app_sg_id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "AppTierInstance"
      Tier = "App"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-tier-asg"
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 2
  vpc_zone_identifier       = var.subnet_ids

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns          = [aws_lb_target_group.app_tg.arn]
  health_check_type          = "EC2"
  health_check_grace_period  = 60

  tag {
    key                 = "Name"
    value               = "AppTierInstance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
