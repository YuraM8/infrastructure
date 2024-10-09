resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_registry_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "teachua-cluster"
  vpc_id          = var.vpc_id
  subnet_ids      = var.public_subnets
  cluster_version = "1.31"
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    eks_nodes = {
      name           = "teachua-node-group"
      instance_types = ["t3.medium"]
      desired_size   = 1
      max_size       = 2
      min_size       = 1
      node_role_arn  = aws_iam_role.eks_node_role.arn

      depends_on = [
         aws_iam_role_policy_attachment.eks_worker_node_policy,
         aws_iam_role_policy_attachment.eks_cni_policy,
         aws_iam_role_policy_attachment.ec2_registry_policy
       ]
    }
  }
#   node_security_group_additional_rules = {
#     ingress_allow_access_from_control_plane = {
#       type                          = "ingress"
#       protocol                      = "tcp"
#       from_port                     = 9443
#       to_port                       = 9443
#       source_cluster_security_group = true
#       description                   = "Allow control plane to access webhook port of AWS load balancer controller"
#     }
#   }
}




output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate" {
  description = "The certificate authority data for the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = "teachua-cluster"
}

output "eks_auth_token" {
  description = "Authentication token for the EKS cluster"
  value       = data.aws_eks_cluster_auth.eks_auth.token
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
