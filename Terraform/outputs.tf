output "cluster_name" {
  description = "update-kubeconfig"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "API Server"
  value       = module.eks.cluster_endpoint
}

output "kubectl_config_command" {
  description = "Command to update kubeconfig for kubectl access"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "ecr_registry_url" {
  description = "ECR Registry URL for the platform API repository"
  value = split("/", aws_ecr_repository.platform_api.repository_url)[0]
}