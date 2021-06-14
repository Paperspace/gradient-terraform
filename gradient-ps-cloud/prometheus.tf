resource "paperspace_script" "gradient_prometheus" {
  count = local.enable_gradient_prometheus_pool

  name        = "Gradient Prometheus setup"
  description = "Gradient Prometheus setup"
  script_text = templatefile("${path.module}/templates/setup-script.tpl", {
    kind            = "worker_public"
    gpu_enabled     = false
    pool_name       = "prometheus"
    pool_type       = "cpu"
    rancher_command = rancher2_cluster.main.cluster_registration_token[0].node_command
    ssh_public_key  = tls_private_key.ssh_key.public_key_openssh
    registry_mirror = local.region_to_mirror[var.region]
  })
  is_enabled = true
  run_once   = true
}

resource "paperspace_machine" "gradient_prometheus" {
  count = local.gradient_prometheus_pool_count

  depends_on = [
    paperspace_script.gradient_prometheus,
    tls_private_key.ssh_key,
  ]

  region           = var.region
  name             = "${var.name}-prometheus${format("%02s", count.index + 1)}"
  machine_type     = var.machine_type_prometheus
  size             = var.machine_storage_prometheus
  billing_type     = "hourly"
  assign_public_ip = true
  template_id      = var.machine_template_id_prometheus
  user_id          = data.paperspace_user.admin.id
  team_id          = data.paperspace_user.admin.team_id
  script_id        = paperspace_script.gradient_prometheus[0].id
  network_id       = paperspace_network.network.handle
  live_forever     = true
  is_managed       = true

  provisioner "remote-exec" {
    inline = ["/bin/true"]
    connection {
      timeout     = "10m"
      type        = "ssh"
      user        = "paperspace"
      host        = self.public_ip_address
      private_key = tls_private_key.ssh_key.private_key_pem
    }
  }
}
