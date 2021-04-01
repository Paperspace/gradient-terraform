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
        registry_mirror = local.region_to_mirror[var.region]
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
    template_id = var.machine_template_id_service
    user_id = data.paperspace_user.admin.id
    team_id = data.paperspace_user.admin.team_id
    script_id = paperspace_script.gradient_service[0].id
    network_id = paperspace_network.network.handle
    live_forever = true
    is_managed = true
}

resource "null_resource" "gradient_service_check" {
    count = local.gradient_service_count

    provisioner "remote-exec" {
        connection {
            bastion_host = paperspace_machine.gradient_main[0].public_ip_address
            bastion_user = "paperspace"
            bastion_private_key = tls_private_key.ssh_key.private_key_pem

            timeout = "10m"
            type     = "ssh"
            user     = "paperspace"
            host     = paperspace_machine.gradient_service[count.index].private_ip_address
            private_key = tls_private_key.ssh_key.private_key_pem
        }
    }
}
