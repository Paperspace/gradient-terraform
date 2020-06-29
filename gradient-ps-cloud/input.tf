variable "admin_email" {
    description = "Paperspace admin API email"
}

variable "admin_user_api_key" {
    description = "Paperspace admin API key"
}

# variable "cluster_id" {}

variable "machine_storage_main" {
    description = "Main storage id"
    default = 100
}
variable "machine_template_id_main" {
    description = "Main template id"
    default = "t04azgph"
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
    default = "t04azgph"
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

variable "network_id" {
    description = "Paperspace private network id"
}

variable "region" {
    description = "Cloud region"
    default = "East Coast (NY2)"
}

variable "ssh_key_path" {
    description = "Private SSH key path"
}

variable "ssh_key_public_path" {
    description = "Public SSH key path"
}

variable "team_id" {
    description = "Cluster team id"
}