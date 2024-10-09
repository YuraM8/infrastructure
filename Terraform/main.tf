provider "aws" {
  region = var.aws_region
}
# provider "kubernetes" {
#   config_path = "~/.kube/config"
# }

module "vpc" {
  source              = "./modules/vpc"
  aws_region          = var.aws_region
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr_a = var.public_subnet_cidr_a
  public_subnet_cidr_b = var.public_subnet_cidr_b
  private_subnet_cidr_a = var.private_subnet_cidr_a
  private_subnet_cidr_b = var.private_subnet_cidr_b
}

module "rds" {
  source             = "./modules/rds"
  private_subnets    = module.vpc.private_subnets
  public_subnet_id   = module.vpc.public_subnets[0]
  db_username        = var.db_username
  db_password        = var.db_password
  key_name           = var.key_name
  private_key_path   = var.private_key_path
  bastion_sg_id      = module.vpc.bastion_sg_id
  db_sg_id           = module.vpc.db_sg_id
}

module "eks" {
  source         = "./modules/eks"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "load_balancer_controller" {
  source          = "./modules/aws_lb_controller"
  cluster_name    = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.eks_cluster_endpoint
  eks_cluster_certificate = module.eks.eks_cluster_certificate
  eks_auth_token          = module.eks.eks_auth_token
  oidc_provider_arn = module.eks.oidc_provider_arn
}
