# VPC variable
variable "aws_region" {
  description = "AWS region"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_a" {
  description = "CIDR block for the public subnet A"
}

variable "public_subnet_cidr_b" {
  description = "CIDR block for the public subnet B"
}

variable "private_subnet_cidr_a" {
  description = "CIDR block for the private subnet A"
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for the private subnet B"
}


