provider "azurerm" {
  version = "~> 2.35.0"
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = var.azure_resource_group_name
  location = var.azure_location
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = var.name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = split(".", var.domain)[0]
  kubernetes_version  = local.k8s_version # "1.18.8" or "1.17.11"

  # to generate ssh keys specify ssh = { key_data: xxxx }
  sku_tier            = "Paid" # Free or Paid; switch to Paid in final

  # node pool 1
  default_node_pool {
    name                 = "svcpusmall"
    vm_size              = "Standard_D4s_v3"
    os_disk_size_gb      = 256 # needed for 1000 iops min on disk attached to some azure vm types
    min_count            = 1
    max_count            = 20
    enable_auto_scaling  = true
    node_labels = {
      "paperspace.com/pool-name" = "services-small"
      "paperspace.com/pool-type" = "cpu"
      "paperspace.com/pool-size" = "small"
      "paperspace.com/pool-workload" = "mixed"
      "paperspace.com/pool-group" = "services"
      "paperspace.com/pool-kind" = "d4s-v3"
    }
  }

  role_based_access_control {
    enabled = true
  }

  identity {
    type = "SystemAssigned"
  }
}

# IMPORTANT: aks has max node pool limit of 10 ("maxAgentPool" attribute).
# We will have to drop number of custom pools to 9 (from 23 in AWS).

# node pool 2
resource "azurerm_kubernetes_cluster_node_pool" "nbgpusmall" {
  depends_on = [azurerm_kubernetes_cluster.default]
  name                  = "nbgpusmall"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.default.id
  vm_size               = "Standard_NC6_Promo"
  os_disk_size_gb       = 256
  min_count             = 0
  max_count             = 20
  enable_auto_scaling   = true
  node_labels = {
    "accelerator" = "nvidia-tesla-k80"
    "paperspace.com/pool-name" = "notebook-gpu-small"
    "paperspace.com/pool-type" = "gpu"
    "paperspace.com/pool-size" = "small"
    "paperspace.com/pool-workload" = "notebook"
    "paperspace.com/pool-group" = "worker"
    "paperspace.com/pool-kind" = "nc6"
  }
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.default.kube_config_raw
}

locals {
    has_k8s = var.k8s_endpoint == "" ? false : true
    has_shared_storage = true
    instance_types = [
        "Standard_D4s_v3",
        "Standard_D16s_v3",
        "Standard_D48s_v3",
        "Standard_NC6_Promo",
        "Standard_NC6s_v2",
        "Standard_NC6s_v3"
    ]
    k8s_version = var.k8s_version == "" ? "1.18.8" : var.k8s_version
}

/*
// Kubernetes
module "kubernetes" {
    source = "./modules/kubernetes"
    enable = !local.has_k8s

    name = var.name
    k8s_version = local.k8s_version
    kubeconfig_path = var.kubeconfig_path

    node_asg_max_sizes = var.k8s_node_asg_max_sizes
    node_asg_min_sizes = var.k8s_node_asg_min_sizes
    node_instance_types = var.k8s_node_instance_types

    write_kubeconfig = var.write_kubeconfig
}

data "aws_eks_cluster" "cluster" {
    count = local.has_k8s ? 0 : 1
    name  = module.kubernetes.cluster_id
}
*/

data "azurerm_kubernetes_cluster" "cluster" {
  depends_on = [azurerm_kubernetes_cluster.default,azurerm_kubernetes_cluster_node_pool.nbgpusmall]
  count = local.has_k8s ? 0 : 1
  name = azurerm_kubernetes_cluster.default.name
  resource_group_name = azurerm_resource_group.default.name
}

provider "helm" {
    alias = "gradient"
    debug = true
    version = "~> 1.2.1"
    kubernetes {
        host                   = element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.host, list("")), 0)
        cluster_ca_certificate = base64decode(element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.cluster_ca_certificate, list("")), 0))
        client_certificate     = base64decode(element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.client_certificate, list("")), 0))
        client_key             = base64decode(element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.client_key, list("")), 0))
        username               = element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.username, list("")), 0)
        password               = element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.password, list("")), 0)
        load_config_file       = "false"
    }
}
provider "kubernetes" {
    alias = "gradient"
    version = "~> 1.13.3"
    host                   = element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.host, list("")), 0)
    cluster_ca_certificate = base64decode(element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.cluster_ca_certificate, list("")), 0))
    client_certificate     = base64decode(element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.client_certificate, list("")), 0))
    client_key             = base64decode(element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.client_key, list("")), 0))
    username               = element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.username, list("")), 0)
    password               = element(concat(data.azurerm_kubernetes_cluster.cluster[*].kube_config.0.password, list("")), 0)
    load_config_file       = "false"
}

// Gradient
module "gradient_processing" {
	source = "../modules/gradient-processing"
    #enabled = module.kubernetes.cluster_status == "" ? false : true
    providers = {
        helm = helm.gradient
        kubernetes = kubernetes.gradient
    }

    amqp_hostname = var.amqp_hostname
    amqp_port = var.amqp_port
    amqp_protocol = var.amqp_protocol
    artifacts_access_key_id = var.artifacts_access_key_id
    artifacts_object_storage_endpoint = var.artifacts_object_storage_endpoint
    artifacts_path = var.artifacts_path
    artifacts_secret_access_key = var.artifacts_secret_access_key
    chart = var.gradient_processing_chart
    cluster_apikey = var.cluster_apikey
    cluster_autoscaler_enabled = false
    cluster_cloud_provider = "azure"
    cluster_handle = var.cluster_handle
    domain = var.domain
    elastic_search_host = var.elastic_search_host
    elastic_search_index = var.elastic_search_index
    elastic_search_password = var.elastic_search_password
    elastic_search_port = var.elastic_search_port
    elastic_search_user = var.elastic_search_user
    helm_repo_username = var.helm_repo_username
    helm_repo_password = var.helm_repo_password
    helm_repo_url = var.helm_repo_url
    letsencrypt_dns_name = var.letsencrypt_dns_name
    letsencrypt_dns_settings = var.letsencrypt_dns_settings
    logs_host = var.logs_host

    gradient_processing_version = var.gradient_processing_version
    name = var.name
    sentry_dsn = var.sentry_dsn
    local_storage_type = "azureDisk"
    local_storage_class = "default"
    shared_storage_path = var.shared_storage_path
    shared_storage_server = var.shared_storage_server
    shared_storage_type = var.shared_storage_type == "" ? "azureFile" : var.shared_storage_type
    shared_storage_class = var.shared_storage_class
    tls_cert = var.tls_cert
    tls_key = var.tls_key
}

output "lb_hostname" {
    value = module.gradient_processing.traefik_service.load_balancer_ingress[0].hostname
}
