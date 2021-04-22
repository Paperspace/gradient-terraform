output "k8s_client_certificate" {
    sensitive = true
    value = rke_cluster.main.client_cert
}
output "k8s_client_key" {
    sensitive = true
    value = rke_cluster.main.client_key
}
output "k8s_cluster_ca_certificate" {
    sensitive = true
    value = rke_cluster.main.ca_crt
}
output "k8s_host" {
    value = rke_cluster.main.api_server_url
}
output "k8s_username" {
    value = rke_cluster.main.kube_admin_user
}
