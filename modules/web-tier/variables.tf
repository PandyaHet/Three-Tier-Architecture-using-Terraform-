variable "instance_type" {
  type        = string
  description = "EC2 instance type for Web tier"
  default     = "t2.micro"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the Web tier instance"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for the Web tier instance"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name for EC2"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of public subnets for Web tier"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for Web tier resources"
}

variable "web_sg_id" {
  type        = string
  description = "Security group ID for Web tier instances"
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use for Web tier instances"
}



