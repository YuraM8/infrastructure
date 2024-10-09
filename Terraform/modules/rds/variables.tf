# RDS Variables
variable "db_username" {
  description = "Username for RDS"
  type        = string
}

variable "db_password" {
  description = "Password for RDS"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
}

variable "private_key_path" {
  description = "Path to the private key"
}

variable "public_subnet_id" {
  description = "Public subnet for bastion"
}

variable "private_subnets" {
  description = "Private subnets for RDS"
}

variable "bastion_sg_id" {
  description = "Security group ID for Bastion host"
}

variable "db_sg_id" {
  description = "Security group ID for RDS"
}

# variable "vpc_id" {
#   description = "id of the VPC"
# }