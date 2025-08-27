variable "ec2_role_name" {
  type        = string
  description = "IAM role name for EC2"
  default     = "ec2-three-tier-role"
}

variable "ec2_profile_name" {
  type        = string
  description = "IAM instance profile name"
  default     = "ec2-three-tier-profile"

}

variable "managed_policy_arns" {
  type        = list(string)
  description = "List of managed policy ARNs"
  default     = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

}