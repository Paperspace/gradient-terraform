variable "admin_email" {}

variable "admin_user_api_key" {}

# variable "cluster_id" {}

variable "machine_storage_main" {
    default = 50
}
variable "machine_template_id_main" {
    default = "t04azgph"
}
variable "machine_type_main" {
    default = "C5"
}

variable "machine_count_worker_cpu" {
    default = 3
}
variable "machine_storage_worker_cpu" {
    default = 50
}
variable "machine_template_id_cpu" {
    default = "t04azgph"
}
variable "machine_type_worker_cpu" {
    default = "C5"
}

variable "machine_count_worker_gpu" {
    default = 3
}
variable "machine_storage_worker_gpu" {
    default = 50
}
variable "machine_template_id_gpu" {
    default = "tmun4o2g"
}
variable "machine_type_worker_gpu" {
    default = "P4000"
}

variable "network_id" {}

variable "region" {
    default = "East Coast (NY2)"
}

variable "ssh_key_private" {}

variable "ssh_key_public" {}

variable "team_id" {}
