locals {
    has_k8s = var.k8s_endpoint == "" ? false : true
    has_shared_storage = var.shared_storage_path == "" ? false : true
    k8s_version = var.k8s_version == "" ? "1.15.11" : var.k8s_version
    service_pool_name = var.k8s_master_nodes[0]["pool-name"]
}

// Kubernetes
module "kubernetes" {
	source          = "./modules/kubernetes"
	enable = !local.has_k8s

	name = var.name
	k8s_version = local.k8s_version
	kubeconfig_path = var.kubeconfig_path
    kubelet_extra_binds = [
        "${var.local_storage_path}:${var.local_storage_path}"
    ]
    master_nodes = var.k8s_master_nodes
    service_pool_name = local.service_pool_name
    setup_docker = var.setup_docker
    setup_nvidia = var.setup_nvidia
    ssh_key = var.ssh_key
    ssh_key_path = var.ssh_key_path
    ssh_user = var.ssh_user
    write_kubeconfig = var.write_kubeconfig
    workers = var.k8s_workers
}

/*
# Storage
module "storage" {
	source = "./modules/storage-metal"
	enable = !local.has_shared_storage

	name = var.name
  security_group_ids = local.has_k8s ? split(",", var.k8s_security_group_ids) : [module.network.private_security_group_id]
	subnet_ids = local.has_k8s ? split(",", var.k8s_subnet_ids) : module.network.private_subnet_ids
}
*/

provider "helm" {
    debug = true
    version = "1.2.1"
    kubernetes {
        host     = module.kubernetes.k8s_host
        username = module.kubernetes.k8s_username

        client_certificate     = module.kubernetes.k8s_client_certificate
        client_key             = module.kubernetes.k8s_client_key
        cluster_ca_certificate = module.kubernetes.k8s_cluster_ca_certificate
        load_config_file = false
    }
}

provider "kubernetes" {
    host     = module.kubernetes.k8s_host
    username = module.kubernetes.k8s_username

    client_certificate     = module.kubernetes.k8s_client_certificate
    client_key             = module.kubernetes.k8s_client_key
    cluster_ca_certificate = module.kubernetes.k8s_cluster_ca_certificate
    load_config_file = false
}

// Gradient
module "gradient_processing" {
	source = "../modules/gradient-processing"
    enabled = module.kubernetes.k8s_host == "" ? false : true

    amqp_hostname = var.amqp_hostname
    amqp_port = var.amqp_port
    amqp_protocol = var.amqp_protocol
    artifacts_access_key_id = var.artifacts_access_key_id
    artifacts_object_storage_endpoint = var.artifacts_object_storage_endpoint
    artifacts_path = var.artifacts_path
    artifacts_secret_access_key = var.artifacts_secret_access_key
    chart = var.gradient_processing_chart
    cluster_apikey = var.cluster_apikey
    cluster_handle = var.cluster_handle
    domain = var.domain

    helm_repo_username = var.helm_repo_username
    helm_repo_password = var.helm_repo_password
    helm_repo_url = var.helm_repo_url
    elastic_search_host = var.elastic_search_host
    elastic_search_index = var.elastic_search_index
    elastic_search_password = var.elastic_search_password
    elastic_search_port = var.elastic_search_port
    elastic_search_user = var.elastic_search_user

    label_selector_cpu = var.cpu_selector
    label_selector_gpu = var.gpu_selector
    local_storage_path = var.local_storage_path
    local_storage_type = "HostPath"
    logs_host = var.logs_host
    gradient_processing_version = var.gradient_processing_version
    name = var.name
    sentry_dsn = var.sentry_dsn
    service_pool_name = local.service_pool_name
    shared_storage_server = var.shared_storage_server
    shared_storage_path = var.shared_storage_path
    shared_storage_type = var.shared_storage_type
    tls_cert = var.tls_cert
    tls_key = var.tls_key
    use_pod_anti_affinity = var.use_pod_anti_affinity
    traefik_prometheus_auth = var.traefik_prometheus_auth
}
