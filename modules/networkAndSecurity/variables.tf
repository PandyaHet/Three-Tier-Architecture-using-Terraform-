variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.4.0/24"]
}

variable "private_app_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.5.0/24"]
}

variable "private_db_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.6.0/24"]
}

variable "your_ip" {
  type        = string
  description = "Your public IP address in CIDR format"
  default     = "192.168.2.46/32"
}   