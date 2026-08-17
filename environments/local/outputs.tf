output "vpc_id" {
  description = "ID da VPC provisionada no ambiente local"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "Nome do cluster EKS provisionado no ambiente local"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint da API Kubernetes do cluster EKS local"
  value       = module.eks.cluster_endpoint
}
