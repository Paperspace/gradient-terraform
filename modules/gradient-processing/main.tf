locals {
    letsencrypt_enabled = (length(var.letsencrypt_dns_settings) != 0 && (var.tls_cert == "" && var.tls_key == ""))
    local_storage_name = "gradient-processing-local"
    helm_repo_url = var.helm_repo_url == "" ? "https://infrastructure-public-chart-museum-repository.storage.googleapis.com" : var.helm_repo_url
    shared_storage_name = "gradient-processing-shared"
    tls_secret_name = "gradient-processing-tls"
}

resource "helm_release" "gradient_processing" {
    name = "gradient-processing"
    repository = local.helm_repo_url
    repository_username = var.helm_repo_username
    repository_password = var.helm_repo_password
    chart = var.chart
    version = var.gradient_processing_version

    set_sensitive {
         name = "global.elasticSearch.password"
         value = var.elastic_search_password
    }
    set_sensitive {
        name = "global.artifactsAccessKeyId"
        value = var.artifacts_access_key_id
    }
    set_sensitive {
        name = "global.artifactsSecretAccessKey"
        value = var.artifacts_secret_access_key
    }
    set_sensitive {
        name  = "secrets.amqpUri"
        value  = "${var.amqp_protocol}://${var.cluster_handle}:${var.cluster_apikey}@${var.amqp_hostname}/"
    }
    set_sensitive {
        name  = "secrets.clusterApikey"
        value = var.cluster_apikey
    }
    set_sensitive {
        name  = "secrets.tlsCert"
        value = var.tls_cert
    }
    set_sensitive {
        name  = "secrets.tlsKey"
        value = var.tls_key
    }

    set_sensitive {
        name = "traefik.acme.dnsProvider.name"
        value = var.letsencrypt_dns_name
    }
    set_sensitive {
        name  = "traefik.ssl.defaultCert"
        value = var.tls_cert == "" ? "null" : base64encode(var.tls_cert)
    }
    set_sensitive {
        name  = "traefik.ssl.defaultKey"
        value = var.tls_key == "" ? "null" : base64encode(var.tls_key)
    }

    dynamic "set_sensitive" {
        for_each = var.letsencrypt_dns_settings

        content {
            name = "traefik.acme.dnsProvider.${var.letsencrypt_dns_name}.${set_sensitive.key}"
            value = set_sensitive.value
        }
    }

    values = [
        templatefile("${path.module}/templates/values.yaml.tpl", {
            enabled = var.enabled

            aws_region = var.aws_region
            artifacts_path = var.artifacts_path
            cluster_autoscaler_autoscaling_groups = var.cluster_autoscaler_autoscaling_groups
            cluster_autoscaler_cloudprovider = var.cluster_autoscaler_cloudprovider
            cluster_autoscaler_enabled = var.cluster_autoscaler_enabled
            cluster_handle = var.cluster_handle
            default_storage_name = local.local_storage_name
            efs_provisioner_enabled = var.shared_storage_type == "efs" || var.local_storage_type == "efs"
            elastic_search_enabled = var.elastic_search_password != ""
            elastic_search_host = var.elastic_search_host
            elastic_search_index = var.elastic_search_index
            elastic_search_port= var.elastic_search_port
            elastic_search_sha = sha256("${var.elastic_search_host}${var.elastic_search_password}${var.elastic_search_port}${var.elastic_search_user}")
            elastic_search_user = var.elastic_search_user
            domain = var.domain
            global_selector = var.global_selector
            label_selector_cpu = var.label_selector_cpu
            label_selector_gpu = var.label_selector_gpu
            letsencrypt_enabled = local.letsencrypt_enabled
            local_storage_name = local.local_storage_name
            local_storage_path = var.local_storage_path
            local_storage_server = var.local_storage_server
            local_storage_type = var.local_storage_type
            logs_host = var.logs_host
            name = var.name
            nfs_client_provisioner_enabled = var.shared_storage_type == "nfs" || var.local_storage_type == "nfs"
            paperspace_base_url = var.paperspace_base_url
            sentry_dsn = var.sentry_dsn
            service_pool_name = var.service_pool_name
            shared_storage_name = local.shared_storage_name
            shared_storage_path = var.shared_storage_path
            shared_storage_server = var.shared_storage_server
            shared_storage_type = var.shared_storage_type
            tls_secret_name = local.tls_secret_name
            use_pod_anti_affinity = var.use_pod_anti_affinity
        })
    ]
}

data "kubernetes_service" "traefik" {
    metadata {
        // Needed to use replace to overcome constant refresh caused by depends_on
        name = "traefik${replace(helm_release.gradient_processing.metadata[0].revision, "/.*/", "")}"
    }
}
