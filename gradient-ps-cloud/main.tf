terraform {
    required_providers {
        cloudflare = {
            source  = "cloudflare/cloudflare"
            version = "~> 2.10.0"
        }
        rancher2 = {
            source = "rancher/rancher2"
            version = "1.10.6"
        }
    }
}

locals {
    asg_types = {
        "C5"={
            type = "cpu"
        },
        "C7"={
            type = "cpu"
        },
        "C10"={
            type = "cpu"
        },
        "P4000"={
            type = "gpu"
        },
        "P5000"={
            type = "gpu"
        },
        "V100"={
            type = "gpu"
        },
    }
    asg_max_sizes = merge({
        "C5"=10,
        "C7"=10,
        "C10"=10,
        "P4000"=10,
        "P5000"=10,
        "V100"=10,
    }, var.asg_min_sizes)

    asg_min_sizes = merge({
        "C5"=0,
        "C7"=0,
        "C10"=0,
        "P4000"=0,
        "P5000"=0,
        "V100"=0,
    }, var.asg_min_sizes)

    cluster_autoscaler_cloudprovider = "paperspace"
    cluster_autoscaler_enabled = true
    enable_gradient_service = var.kind == "singlenode" ? 0 : 1
    gradient_main_count = var.kind == "singlenode" ? 1 : 3
    gradient_service_count = var.kind == "singlenode" ? 0 : 2
    k8s_version = var.k8s_version == "" ? "1.15.12" : var.k8s_version
    kubeconfig = yamldecode(rancher2_cluster_sync.main.kube_config)

    storage_path = "/srv/gradient"
    storage_server = paperspace_machine.gradient_main[0].private_ip_address
    storage_type = "nfs"
    ssh_key_path = "${path.module}/ssh_key"
}

provider "cloudflare" {
    version = "~> 2.0"
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

data "paperspace_user" "admin" {
    email = var.admin_email
    team_id = var.team_id
}

resource "tls_private_key" "ssh_key" {
    algorithm = "RSA"
}

resource "paperspace_script" "gradient_main" {
    name = "Main setup"
    description = "Add public SSH key on machine create"
    script_text = templatefile("${path.module}/templates/setup-script.tpl", {
        kind = var.kind == "singlenode" ? "main_single" : "main"
        gpu_enabled = false
        pool_name = "main"
        pool_type = "cpu"
        rancher_command =  rancher2_cluster.main.cluster_registration_token[0].node_command
        ssh_public_key = tls_private_key.ssh_key.public_key_openssh
    })

    is_enabled = true
    run_once = true

    provisioner "local-exec" {
        command = <<EOF
            sleep 20
        EOF
    }
}

resource "paperspace_network" "network" {
    team_id = var.team_id_integer
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
    host     = local.kubeconfig["clusters"][0]["cluster"]["server"]
    token = local.kubeconfig["users"][0]["user"]["token"]
    
    load_config_file = false
}

// Gradient
module "gradient_processing" {
    source = "../modules/gradient-processing"
    enabled = rancher2_cluster_sync.main.id == "" ? false : true

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

    letsencrypt_dns_name = var.letsencrypt_dns_name
    letsencrypt_dns_settings = var.letsencrypt_dns_settings
    local_storage_server = local.storage_server
    local_storage_path = local.storage_path
    local_storage_type = local.storage_type
    logs_host = var.logs_host
    gradient_processing_version = var.gradient_processing_version
    name = var.name
    paperspace_base_url = var.api_host
    sentry_dsn = var.sentry_dsn
    shared_storage_server = local.storage_server
    shared_storage_path = local.storage_path
    shared_storage_type = local.storage_type
    tls_cert = var.tls_cert
    tls_key = var.tls_key
}

resource "rancher2_cluster" "main" {
  name = var.cluster_handle
  description = var.name
  rke_config {
        kubernetes_version = "v${local.k8s_version}-rancher1-1"

        dns {
            node_selector = {
              "paperspace.com/pool-name" = "services-small"
            }
        }

        ingress {
            provider = "none"
        }

        upgrade_strategy {
            drain = false
            max_unavailable_controlplane = "1"
            max_unavailable_worker       = "10%"
        }
  }
}

resource "rancher2_cluster_sync" "main" {
    depends_on = [paperspace_machine.gradient_main]
    cluster_id =  rancher2_cluster.main.id
    state_confirm = 10

    timeouts {
        create = "8m"
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
    })
    is_enabled = true
    run_once = true
}

resource "paperspace_machine" "gradient_service" {
    count = local.gradient_service_count

    depends_on = [
        paperspace_script.gradient_service,
        tls_private_key.ssh_key,
    ]

    region = var.region
    name = "${var.name}-service${format("%02s", count.index + 1)}"
    machine_type = var.machine_type_service
    size = var.machine_storage_service
    billing_type = "hourly"
    assign_public_ip = true
    template_id = var.machine_template_id_service
    user_id = data.paperspace_user.admin.id
    team_id = data.paperspace_user.admin.team_id
    script_id = paperspace_script.gradient_service[0].id
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
}

resource "paperspace_script" "gradient_service" {
    count = local.enable_gradient_service

    name = "Gradient service setup"
    description = "Gradient service setup"
    script_text = templatefile("${path.module}/templates/setup-script.tpl", {
        kind = "worker"
        gpu_enabled = false
        pool_name = "services-small"
        pool_type = "cpu"
        rancher_command =  rancher2_cluster.main.cluster_registration_token[0].node_command
        ssh_public_key = tls_private_key.ssh_key.public_key_openssh
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
    count = var.cloudflare_api_key == "" && var.cloudflare_email == "" && var.cloudflare_zone_id == "" ? 0 : 1
    zone_id = var.cloudflare_zone_id
    name    = var.domain
    value   = paperspace_machine.gradient_main[0].public_ip_address
    type    = "A"
    ttl     = 3600
    proxied = false
}

resource "cloudflare_record" "subdomain_wildcard" {
    count = var.cloudflare_api_key == "" && var.cloudflare_email == "" && var.cloudflare_zone_id == "" ? 0 : 1
    zone_id = var.cloudflare_zone_id
    name    = "*.${var.domain}"
    value   = paperspace_machine.gradient_main[0].public_ip_address
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