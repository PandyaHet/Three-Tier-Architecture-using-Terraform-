# variable "instance_type" {
#   type        = string
#   description = "EC2 instance type for the App tier"
#   default     = "t2.micro"
# }

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the App instance"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for the App instance"
}

# variable "iam_instance_profile" {
#   type        = string
#   description = "IAM instance profile name for the App instance"
# }

variable "instance_type" {
  type        = string
  description = "EC2 instance type for App tier"
  default     = "t2.micro"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnets for App tier"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for App tier resources"
}

variable "app_sg_id" {
  type        = string
  description = "Security group ID for App tier instances"
}

variable "internal_elb_sg_id" {
  type        = string
  description = "Security group ID for internal ALB"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name for EC2"
}