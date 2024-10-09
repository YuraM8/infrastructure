
resource "aws_iam_policy" "load_balancer_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        Resource = "*"
      },
    ]
  })
}


module "aws_load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.3.1"

  role_name = "aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    eks = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# Прикріплення власної політики до ролі
resource "aws_iam_role_policy_attachment" "load_balancer_controller_policy_attachment" {
  role       = module.aws_load_balancer_controller_irsa_role.iam_role_name
  policy_arn = aws_iam_policy.load_balancer_controller_policy.arn
}

provider "helm" {
  kubernetes {
    host                   = var.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.eks_cluster_certificate)
    token                  = var.eks_auth_token
  }
}

# Розгортання AWS Load Balancer Controller 
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system" 
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.4.0"

  set {
    name  = "clusterName"
    value = "teachua-cluster"
  }

  set {
    name  = "serviceAccount.create"
    value = "true" 
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
  }
}
