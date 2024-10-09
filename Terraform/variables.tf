variable "aws_region" {
  description = "AWS region to deploy resources in"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_a" {
  description = "CIDR block for public subnet A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_b" {
  description = "CIDR block for public subnet B"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr_a" {
  description = "CIDR block for private subnet A"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for private subnet B"
  type        = string
  default     = "10.0.4.0/24"
}

variable "instance_type" {
  description = "Instance type for EC2"
  default     = "t2.micro"
}

variable "db_name" {
  description = "RDS database name"
  default     = "teachua"
}

variable "db_username" {
  description = "Username for RDS"
  default     = "yura"
}

variable "db_password" {
  description = "Password for RDS"
  default     = "PaSSword10"
}

variable "key_name" {
  description = "The SSH key name to acces the EC2 instance"
  type        = string
  default     = "yura"
}

variable "private_key_path" {
  description = "Path to the SSH private key"
  type        = string
  default     = "/home/yura/terraform/yura.pem"
}

