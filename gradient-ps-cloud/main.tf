provider "paperspace" {
    region = var.region
    api_key = var.admin_user_api_key
}

data "paperspace_user" "admin" {
    email = var.admin_email
    team_id = var.team_id
}

data "paperspace_network" "network" {
    id = var.network_id
}

resource "paperspace_script" "add_public_ssh_key" {
  name = "Add public SSH key"
  description = "Add public SSH key on machine create"
  script_text = <<EOF
#!/bin/bash
echo "${var.ssh_key_public}" >> /home/paperspace/.ssh/authorized_keys
EOF
  is_enabled = true
  run_once = true
}

resource "paperspace_machine" "gradient_main" {
    region = var.region
    name = "${var.name}-main"
    machine_type = var.machine_type_main
    size = var.machine_storage_main
    billing_type = "hourly"
    assign_public_ip = true
    template_id = var.machine_template_id_main
    user_id = data.paperspace_user.admin.id
    team_id = data.paperspace_user.admin.team_id
    script_id = paperspace_script.add_public_ssh_key.id
    # cluster_id = var.cluster_id // coming soon

    provisioner "local-exec" {
        command = <<EOF
            ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
            -i '${paperspace_machine.gradient_main.public_ip_address},' \
            -e "install_nfs_server=true" \
            -e "nfs_subnet_host_with_netmask=${data.paperspace_network.network.network}/${data.paperspace_network.network.netmask}" \
            ansible/playbook-gradient-metal-ps-cloud-node.yaml
        EOF
    }
}

resource "paperspace_machine" "gradient_workers_cpu" {
    count = var.machine_count_worker_cpu
    region = var.region
    name = "${var.name}-worker-cpu-${count.index}"
    machine_type = var.machine_type_worker_cpu
    size = var.machine_storage_worker_cpu
    billing_type = "hourly"
    assign_public_ip = true
    template_id = var.machine_template_id_cpu
    user_id = data.paperspace_user.admin.id
    team_id = data.paperspace_user.admin.team_id
    script_id = paperspace_script.add_public_ssh_key.id
    # cluster_id = var.cluster_id

    provisioner "local-exec" {
        command = <<EOF
            ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
            -i '${self.public_ip_address},' \
            ansible/playbook-gradient-metal-ps-cloud-node.yaml
        EOF
    }
}

resource "paperspace_machine" "gradient_workers_gpu" {
    count = var.machine_count_worker_gpu
    region = var.region
    name = "${var.name}-worker-gpu-${count.index}"
    machine_type = var.machine_type_worker_gpu
    size = var.machine_storage_worker_gpu
    billing_type = "hourly"
    assign_public_ip = true
    template_id = var.machine_template_id_gpu
    user_id = data.paperspace_user.admin.id
    team_id = data.paperspace_user.admin.team_id
    script_id = paperspace_script.add_public_ssh_key.id
    # cluster_id = var.cluster_id

    provisioner "local-exec" {
        command = <<EOF
            ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
            -i '${self.public_ip_address},' \
            ansible/playbook-gradient-metal-ps-cloud-node.yaml
        EOF
    }
}

module "gradient_metal" {
    source = "../gradient-metal"

    name = var.name

    amqp_hostname = var.amqp_hostname

    artifacts_access_key_id = var.artifacts_access_key_id
    artifacts_path = var.artifacts_path
    artifacts_secret_access_key = var.artifacts_secret_access_key
    sentry_dsn = var.sentry_dsn

    cluster_handle = var.cluster_handle
    cluster_apikey = var.cluster_apikey

    domain = var.domain
    gradient_processing_version = var.gradient_processing_version

    elastic_search_host = var.elastic_search_host
    elastic_search_index = var.name
    elastic_search_password = var.elastic_search_password
    elastic_search_user = "elastic"

    helm_repo_password = var.helm_repo_password
    helm_repo_username = var.helm_repo_username
    helm_repo_url = var.helm_repo_url
    kubeconfig_path = var.kubeconfig_path

    logs_host = var.logs_host
    letsencrypt_dns_name = var.letsencrypt_dns_name
    letsencrypt_dns_settings = var.letsencrypt_dns_settings
    traefik_prometheus_auth = var.traefik_prometheus_auth

    k8s_master_node = {
        ip = paperspace_machine.gradient_main.public_ip_address
        internal-address = paperspace_machine.gradient_main.private_ip_address
        pool-type = "cpu"
        pool-name = "metal-cpu"
    }
    k8s_workers = concat(
        [
            for cpu_worker in paperspace_machine.gradient_workers_cpu : {
                ip = cpu_worker.public_ip_address
                internal-address = cpu_worker.private_ip_address
                pool-type = "cpu"
                pool-name = "metal-cpu"
            }
        ],
        [
            for gpu_worker in paperspace_machine.gradient_workers_gpu : {
                ip = gpu_worker.public_ip_address
                internal-address = gpu_worker.private_ip_address
                pool-type = "gpu"
                pool-name = "metal-gpu"
            }
        ]
    )

    shared_storage_path = "/srv/gradient"
    shared_storage_server = paperspace_machine.gradient_main.private_ip_address
    ssh_key = var.ssh_key_private
    ssh_user = "paperspace"
}

output "main_publicIpAddress" {
  value = paperspace_machine.gradient_main.public_ip_address
}
