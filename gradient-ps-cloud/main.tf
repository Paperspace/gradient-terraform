terraform {
    required_providers {
        cloudflare = {
            source  = "cloudflare/cloudflare"
            version = "~> 2.10.0"
        }
        paperspace = {
            source = "Paperspace/paperspace"
            version = "0.4.0"
        }
        rancher2 = {
            source = "rancher/rancher2"
            version = "1.10.6"
        }
    }
}

locals {
    asg_types = var.gradient_machine_config == "paperspace-public" ? merge(local.base_asg_types, {
        "Free-CPU"={
            type = "cpu"
        }
        "Free-GPU"={
            type = "gpu"
        }
        "Free-P5000"={
            type = "gpu"
        }
    }) : local.base_asg_types

    base_asg_types = {
        "C5"={
            type = "cpu"
        },
        "C7"={
            type = "cpu"
        },
        "P4000"={
            type = "gpu"
        },
        "P5000"={
            type = "gpu"
        },
        "P6000"={
            type = "gpu"
        },
        "V100"={
            type = "gpu"
        },
    }

    region_to_mirror = {
        "East Coast (NY2)": "http://docker-registry-mirror.paperspace.io",
        "Europe (AMS1)": "http://am1-docker-registry-mirror.paperspace.io",
        "West Coast (CA1)": "http://ca1-docker-registry-mirror.paperspace.io",
    }

    asg_max_sizes = var.gradient_machine_config == "paperspace-public" ? merge(local.base_asg_max_sizes, {
        "Free-CPU"=10,
        "Free-GPU"=10,
        "Free-P5000"=10,
    }) : local.base_asg_max_sizes
    base_asg_max_sizes = merge({
        "C5"=10,
        "C7"=10,
        "P4000"=10,
        "P5000"=10,
        "P6000"=10,
        "V100"=10,
    }, var.asg_min_sizes)

    asg_min_sizes = var.gradient_machine_config == "paperspace-public" ? merge(local.base_asg_min_sizes, {
        "Free-CPU"=0,
        "Free-GPU"=0,
        "Free-P5000"=0,
    }) : local.base_asg_min_sizes
    base_asg_min_sizes = merge({
        "C5"=0,
        "C7"=0,
        "P4000"=0,
        "P5000"=0,
        "P6000"=0,
        "V100"=0,
    }, var.asg_min_sizes)

    is_public_cluster = var.gradient_machine_config == "paperspace-public"

    cluster_autoscaler_cloudprovider = "paperspace"
    cluster_autoscaler_enabled = true
    dns_node_selector = var.kind == "multinode" ? {} : { "paperspace.com/pool-name" = "services-small" }
    enable_gradient_service = var.kind == "multinode" ? 1 : 0
    enable_gradient_lb = var.kind == "multinode" ? 1 : 0
    gradient_lb_count = var.kind == "multinode" ? 1 : 0
    gradient_main_count = var.kind == "multinode" ? 3 : 1
    gradient_service_count = var.kind == "multinode" ? 3 : 0
    k8s_version = var.k8s_version == "" ? "1.16.15" : var.k8s_version
    kubeconfig = yamldecode(rancher2_cluster_sync.main.kube_config)
    lb_ips = var.kind == "multinode" ? paperspace_machine.gradient_lb.*.public_ip_address : [paperspace_machine.gradient_main[0].public_ip_address]
    lb_pool_name = var.kind == "multinode" ? "lb" : "services-small"

    local_storage_path = var.local_storage_path == "" ? "/srv/gradient" : var.local_storage_path
    local_storage_type = var.local_storage_type == "" ? "nfs" : var.local_storage_type
    shared_storage_path = var.shared_storage_path == "/" ? "/srv/gradient" : var.shared_storage_path
    shared_storage_type = var.shared_storage_type == "" ? "nfs" : var.shared_storage_type
    legacy_datasets_pvc_name = var.gradient_machine_config == "paperspace-public" ? "gradient-processing-shared" : ""
    legacy_datasets_sub_path = var.gradient_machine_config == "paperspace-public" ? "datasets" : ""

    ssh_key_path = "${path.module}/ssh_key"
    storage_server = paperspace_machine.gradient_main[0].private_ip_address

    k8s_version_to_rke_version = {
        "1.16.15"="v1.16.15-rancher1-4",
        "1.15.12"="v1.15.12-rancher2-7",
    }
}

provider "cloudflare" {
    email   = var.cloudflare_email
    api_key = var.cloudflare_api_key
}

provider "paperspace" {
    region = var.region
    api_host = var.api_host
    api_key = var.admin_user_api_key
}

provider "rancher2" {
    api_url = var.rancher_api_url
    access_key = var.rancher_access_key
    secret_key = var.rancher_secret_key
}

provider "helm" {
    debug = true
    version = "1.2.1"
    kubernetes {
        host     = local.kubeconfig["clusters"][0]["cluster"]["server"]
        token = local.kubeconfig["users"][0]["user"]["token"]

        load_config_file = false
    }
}
provider "kubernetes" {
    version = "1.13.3"

    host     = local.kubeconfig["clusters"][0]["cluster"]["server"]
    token = local.kubeconfig["users"][0]["user"]["token"]

    load_config_file = false
}
data "paperspace_user" "admin" {
    email = var.admin_email
    team_id = var.team_id
}

resource "tls_private_key" "ssh_key" {
    algorithm = "RSA"
}

resource "paperspace_network" "network" {
    team_id = var.team_id_integer
}

resource "paperspace_script" "gradient_main" {
    name = "Main setup"
    description = "Add public SSH key on machine create"
    script_text = templatefile("${path.module}/templates/setup-script.tpl", {
        kind = var.kind == "multinode" ? "main" : "main_single"
        gpu_enabled = false
        pool_name = "main"
        pool_type = "cpu"
        rancher_command =  rancher2_cluster.main.cluster_registration_token[0].node_command
        ssh_public_key = tls_private_key.ssh_key.public_key_openssh
        registry_mirror = local.region_to_mirror[var.region]
    })

    is_enabled = true
    run_once = true

    provisioner "local-exec" {
        command = <<EOF
            sleep 20
        EOF
    }
}
resource "paperspace_machine" "gradient_main" {
    count = local.gradient_main_count

    depends_on = [
        paperspace_script.gradient_main,
        tls_private_key.ssh_key,
    ]

    region = var.region
    name = "${var.name}-main${format("%02s", count.index + 1)}"
    machine_type = var.machine_type_main
    size = var.machine_storage_main
    billing_type = "hourly"
    assign_public_ip = true
    template_id = var.machine_template_id_main
    user_id = data.paperspace_user.admin.id
    team_id = data.paperspace_user.admin.team_id
    script_id = paperspace_script.gradient_main.id
    network_id = paperspace_network.network.handle
    live_forever = true
    is_managed = true

    provisioner "remote-exec" {
        connection {
            timeout = "10m"
            type     = "ssh"
            user     = "paperspace"
            host     = self.public_ip_address
            private_key = tls_private_key.ssh_key.private_key_pem
        }
    }

    provisioner "local-exec" {
        command = <<EOF
            echo "${tls_private_key.ssh_key.private_key_pem}" > ${local.ssh_key_path} && chmod 600 ${local.ssh_key_path} && \
            ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
            --key-file ${local.ssh_key_path} \
            -i '${self.public_ip_address},' \
            -e "install_nfs_server=true" \
            -e "nfs_subnet_host_with_netmask=${paperspace_network.network.network}/${paperspace_network.network.netmask}" \
            ${path.module}/ansible/playbook-gradient-metal-ps-cloud-node.yaml
        EOF
    }
}

resource "null_resource" "check_cluster" {
    triggers = {
        cluster_id = rancher2_cluster_sync.main.id
    }

    provisioner "local-exec" {
        command     = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done"
        environment = {
            ENDPOINT = local.kubeconfig["clusters"][0]["cluster"]["server"]
        }
    }
}

// Gradient
module "gradient_processing" {
    source = "../modules/gradient-processing"
    enabled = null_resource.check_cluster.id == "" ? false : true
    is_public_cluster = local.is_public_cluster

    amqp_hostname = var.amqp_hostname
    amqp_port = var.amqp_port
    amqp_protocol = var.amqp_protocol
    artifacts_access_key_id = var.artifacts_access_key_id
    artifacts_object_storage_endpoint = var.artifacts_object_storage_endpoint
    artifacts_path = var.artifacts_path
    artifacts_secret_access_key = var.artifacts_secret_access_key
    chart = var.gradient_processing_chart
    cluster_apikey = var.cluster_apikey
    cluster_autoscaler_cloudprovider = "paperspace"
    cluster_autoscaler_enabled = true
    cluster_autoscaler_delay_after_add = "2m"
    cluster_autoscaler_unneeded_time = "8m"
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

    lb_count = length(local.lb_ips)
    lb_pool_name = local.lb_pool_name
    letsencrypt_dns_name = var.letsencrypt_dns_name
    letsencrypt_dns_settings = var.letsencrypt_dns_settings
    local_storage_config = var.local_storage_config
    local_storage_server = local.storage_server
    local_storage_path = local.local_storage_path
    local_storage_type = local.local_storage_type
    logs_host = var.logs_host
    gradient_processing_version = var.gradient_processing_version
    name = var.name
    paperspace_base_url = var.api_host
    sentry_dsn = var.sentry_dsn
    shared_storage_config = var.shared_storage_config
    shared_storage_server = local.storage_server
    shared_storage_path = local.shared_storage_path
    shared_storage_type = local.shared_storage_type
    tls_cert = var.tls_cert
    tls_key = var.tls_key
    pod_assignment_label_name = "paperspace.com/pool-name"
    legacy_datasets_pvc_name = local.legacy_datasets_pvc_name
    legacy_datasets_sub_path = local.legacy_datasets_sub_path
    anti_crypto_miner_regex = var.anti_crypto_miner_regex
    prometheus_resources = var.prometheus_resources
    cert_manager_enabled = var.cert_manager_enabled
    image_cache_enabled = var.image_cache_enabled
    image_cache_list = var.image_cache_list
}

resource "rancher2_cluster" "main" {
  name = var.cluster_handle
  description = var.name
  rke_config {
        kubernetes_version = local.k8s_version_to_rke_version[local.k8s_version]

        dns {
            node_selector = local.dns_node_selector
        }

        ingress {
            provider = "none"
        }

        upgrade_strategy {
            drain = false
            max_unavailable_controlplane = "1"
            max_unavailable_worker       = "10%"
        }

        services {
            kubelet {
                extra_args = {
                    "system-reserved" = "cpu=500m,memory=256Mi,ephemeral-storage=5Gi"
                    "kube-reserved-cgroup" = "/podruntime.slice"
                    "kube-reserved" = "cpu=500m,memory=256Mi,ephemeral-storage=10Gi"
                }
            }
        }
  }
}

resource "rancher2_cluster_sync" "main" {
    depends_on = [paperspace_machine.gradient_main, paperspace_machine.gradient_lb, null_resource.gradient_service_check]
    cluster_id =  rancher2_cluster.main.id
    state_confirm = 1

    timeouts {
        create = "15m"
    }
}

resource "paperspace_autoscaling_group" "main" {
    for_each = local.asg_types

    name = "${var.cluster_handle}-${each.key}"
    cluster_id = var.cluster_handle
    machine_type = each.key
    template_id = each.value.type == "cpu" ? var.machine_template_id_cpu : var.machine_template_id_gpu
    max = local.asg_max_sizes[each.key]
    min = local.asg_min_sizes[each.key]
    network_id = paperspace_network.network.handle
    startup_script_id = paperspace_script.autoscale[each.key].id
}

resource "paperspace_script" "autoscale" {
    for_each = local.asg_types

    name = "Autoscale cluster ${each.key}"
    description = "Autoscales cluster ${each.key}"
    script_text = templatefile("${path.module}/templates/setup-script.tpl", {
        kind = "autoscale_worker"
        gpu_enabled = each.value.type == "gpu"
        pool_name = each.key
        pool_type = each.value.type
        rancher_command =  rancher2_cluster.main.cluster_registration_token[0].node_command
        ssh_public_key = tls_private_key.ssh_key.public_key_openssh
        registry_mirror = local.region_to_mirror[var.region]
    })
    is_enabled = true
    run_once = true
}
resource "null_resource" "register_managed_cluster_network" {
    provisioner "local-exec" {
        command = <<EOF
            curl -H 'Content-Type:application/json' -H 'X-API-Key: ${var.cluster_apikey}' -XPOST '${var.api_host}/clusters/updateCluster' -d '{"id":"${var.cluster_handle}", "attributes":{"networkId":"${paperspace_network.network.handle}"}}'
        EOF
    }
}

resource "null_resource" "register_managed_cluster_machine_main" {
    count = local.gradient_main_count

    provisioner "local-exec" {
        command = <<EOF
            curl -H 'Content-Type:application/json' -H 'X-API-Key: ${var.cluster_apikey}' -XPOST '${var.api_host}/clusterMachines/register' -d '{"clusterId":"${var.cluster_handle}", "machineId":"${paperspace_machine.gradient_main[count.index].id}"}'
        EOF
    }
}

resource "cloudflare_record" "subdomain" {
    count = var.cloudflare_api_key == "" || var.cloudflare_email == "" || var.cloudflare_zone_id == ""  ? 0 : length(local.lb_ips)
    zone_id = var.cloudflare_zone_id
    name    = var.domain
    value   = local.lb_ips[count.index]
    type    = "A"
    ttl     = 3600
    proxied = false
}

resource "cloudflare_record" "subdomain_wildcard" {
    count = var.cloudflare_api_key == "" || var.cloudflare_email == "" || var.cloudflare_zone_id == ""  ? 0 : length(local.lb_ips)
    zone_id = var.cloudflare_zone_id
    name    = "*.${var.domain}"
    value   = local.lb_ips[count.index]
    type    = "A"
    ttl     = 3600
    proxied = false
}

output "main_node_public_ip_address" {
  value = paperspace_machine.gradient_main[0].public_ip_address
}

output "network_handle" {
    value = paperspace_network.network.handle
}
