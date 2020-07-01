variable "admin_email" {
    description = "Paperspace admin API email"
}

variable "admin_user_api_key" {
    description = "Paperspace admin API key"
}

variable "cloudflare_api_token" {
    description = "Cloudflare API token"
    default = " "
}
variable "cloudflare_email" {
    description = "Cloudflare email"
    default = " "
}
variable "cloudflare_zone_id" {
    description = "Cloudflare zone id"
    default = " "
}

variable "cluster_id_integer" {
    description = "Cluster id integer"
}

variable "machine_storage_main" {
    description = "Main storage id"
    default = 100
}
variable "machine_template_id_main" {
    description = "Main template id"
    default = "tmun4o2g" # tmun4o2g is pre-installed with nvidia and docker; docker is needed for cpu, whereas nvidia is needed for gpu, but using this template introduces very little bloat and speeds up node configuration
}
variable "machine_type_main" {
    description = "Main machine type"
    default = "C5"
}

variable "machine_count_worker_cpu" {
    description = "Number of CPU workers"
    default = 3
}
variable "machine_storage_worker_cpu" {
    description = "CPU worker storage"
    default = 100
}
variable "machine_template_id_cpu" {
    description = "CPU template id"
    default = "tmun4o2g" # tmun4o2g is pre-installed with nvidia and docker; docker is needed for cpu, whereas nvidia is needed for gpu, but using this template introduces very little bloat and speeds up node configuration
}
variable "machine_type_worker_cpu" {
    description = "CPU worker machine type"
    default = "C5"
}

variable "machine_count_worker_gpu" {
    description = "Number of GPU workers"
    default = 3
}
variable "machine_storage_worker_gpu" {
    description = "GPU worker storage"
    default = 100
}
variable "machine_template_id_gpu" {
    description = "GPU template id"
    default = "tmun4o2g"
}
variable "machine_type_worker_gpu" {
    description = "GPU worker machine type"
    default = "P4000"
}

variable "api_host" {
    description = "api host"
    default = "api.paperspace.io"
}

variable "region" {
    description = "Cloud region"
    default = "East Coast (NY2)"
}

variable "ssh_key_private" {
    description = "Private SSH key content"
}

variable "ssh_key_public" {
    description = "Public SSH key content"
}

variable "team_id" {
    description = "Cluster team id"
}

variable "team_id_integer" {
    description = "Cluster team id integer"
}
