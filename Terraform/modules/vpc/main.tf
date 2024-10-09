resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "teachua-vpc"
  }
}

# Public subnet A
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_a
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Tier = "Public-subnet-a"
    "kubernetes.io/role/elb" = "1"
  }
}

# Public subnet B
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_b
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Tier = "Public-subnet-b"
    "kubernetes.io/role/elb" = "1"
  }
}

# Private subnet A
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_a
  availability_zone = "eu-central-1a"

  tags = {
    Tier = "Private-subnet-a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Private subnet B
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_b
  availability_zone = "eu-central-1b"

  tags = {
    Tier = "Private-subnet-b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
 
  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Security Group для публічної мережі
resource "aws_security_group" "public_sg" {
  name   = "public-security-group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port    = 9443
    to_port      = 9443
    protocol     = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description  = "Allow control plane to access webhook port"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public"
  }
}

# Security Group для приватної мережі (порт 8080)
resource "aws_security_group" "private_sg" {
  name   = "private-security-group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = [aws_subnet.public_a.cidr_block, aws_subnet.public_b.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private"
  }
}

# Security Group для бази даних (порт 3306)
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_a.cidr_block, aws_subnet.private_b.cidr_block, aws_subnet.public_a.cidr_block, aws_subnet.public_b.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-security-group"
  }
}

# Security Group для Bastion-хоста (порт 22)
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-security-group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnets" {
  value = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}

