locals {
    local_storage_name = "gradient-processing-local"
    shared_storage_name = "gradient-processing-shared"
    tls_secret_name = "gradient-processing-tls"
}

data "helm_repository" "paperspace" {
    name = "paperspace"
    url  = "https://infrastructure-public-chart-museum-repository.storage.googleapis.com"
}

resource "helm_release" "gradient_processing" {
    name = "gradient-processing"
    repository = data.helm_repository.paperspace.metadata[0].name
    chart      = var.chart
    version = var.gradient_processing_version
    values = [
        templatefile("${path.module}/templates/values.yaml.tpl", {
            enabled = var.enabled

            amqp_uri = "${var.amqp_protocol}://${var.cluster_handle}:${var.cluster_apikey}@${var.amqp_hostname}/"
            aws_region = var.aws_region
            artifacts_access_key_id = var.artifacts_access_key_id
            artifacts_path = var.artifacts_path
            artifacts_secret_access_key = var.artifacts_secret_access_key
            cluster_autoscaler_enabled = var.cluster_autoscaler_enabled
            cluster_apikey = var.cluster_apikey
            cluster_handle = var.cluster_handle
            default_storage_name = local.local_storage_name
            efs_provisioner_enabled = var.shared_storage_type == "efs" || var.local_storage_type == "efs"
            elastic_search_host = var.elastic_search_host
            elastic_search_port= var.elastic_search_port
            elastic_search_password = var.elastic_search_password
            elastic_search_user = var.elastic_search_user
            domain = var.domain
            global_selector = var.global_selector
            label_selector_cpu = var.label_selector_cpu
            label_selector_gpu = var.label_selector_gpu
            local_storage_name = local.local_storage_name
            local_storage_path = var.local_storage_path
            local_storage_server = var.local_storage_server
            local_storage_type = var.local_storage_type
            logs_host = var.logs_host
            name = var.name
            nfs_client_provisioner_enabled = var.shared_storage_type == "nfs" || var.local_storage_type == "nfs"
            sentry_dsn = var.sentry_dsn
            service_pool_name = var.service_pool_name
            shared_storage_name = local.shared_storage_name
            shared_storage_path = var.shared_storage_path
            shared_storage_server = var.shared_storage_server
            shared_storage_type = var.shared_storage_type
            tls_cert = var.tls_cert
            tls_key = var.tls_key
            tls_secret_name = local.tls_secret_name
            use_pod_anti_affinity = var.use_pod_anti_affinity
        })
    ]
}

data "kubernetes_service" "traefik" {
    depends_on = [helm_release.gradient_processing]
    metadata {
        name = "traefik"
    }
}
