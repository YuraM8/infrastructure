variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "Endpoint для підключення до EKS"
  type        = string
}

variable "eks_cluster_certificate" {
  description = "Сертифікат для EKS"
  type        = string
}

variable "eks_auth_token" {
  description = "The authentication token for the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "for add role"
}
