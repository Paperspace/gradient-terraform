output "k8s_cluster_ca_certificate" {
    value = base64decode(module.eks.cluster_certificate_authority_data)
}

output "k8s_host" {
    value = element(concat(data.aws_eks_cluster.cluster[*].endpoint, list("")), 0)
}

output "k8s_token" {
    value = element(concat(data.aws_eks_cluster_auth.cluster[*].token, list("")), 0)
}

output "cluster_id" {
    value = module.eks.cluster_id
}

output "cluster_status" {
    value = null_resource.cluster_status.id
}