data "aws_ami" "amazon_linux_2" {
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



module "iam" {
  source = "./modules/iam"
}
module "S3" {
    source = "./modules/S3"
}
module "networkAndSecurity" {
  source = "./modules/networkAndSecurity"
}


module "app-tier" {
  source               = "./modules/app-tier"
  subnet_id            = module.networkAndSecurity.private_app_subnets[0]
  security_group_id    = module.networkAndSecurity.security_group_ids["app_sg"]
  subnet_ids           = module.networkAndSecurity.private_app_subnets
  vpc_id               = module.networkAndSecurity.vpc_id
  app_sg_id            = module.networkAndSecurity.security_group_ids["app_sg"]
  internal_elb_sg_id   = module.networkAndSecurity.security_group_ids["internal_elb_sg"]
  iam_instance_profile = module.iam.ec2_profile_name
}

module "web-tier" {
  source               = "./modules/web-tier"
  subnet_id            = module.networkAndSecurity.public_web_subnets[0]
  security_group_id    = module.networkAndSecurity.security_group_ids["web_sg"]
  iam_instance_profile = module.iam.ec2_profile_name
  subnet_ids           = module.networkAndSecurity.public_web_subnets
  vpc_id               = module.networkAndSecurity.vpc_id
  web_sg_id            = module.networkAndSecurity.security_group_ids["web_sg"]
  ami_id               = data.aws_ami.amazon_linux_2.id  # or use output from a custom AMI module

}