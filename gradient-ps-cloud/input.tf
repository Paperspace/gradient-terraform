variable "admin_email" {
    description = "Paperspace admin API email"
}

variable "admin_user_api_key" {
    description = "Paperspace admin API key"
}

variable "api_host" {
    description = "api host"
    default = "https://api.paperspace.io"
}

variable "asg_max_sizes" {
    description = "Autoscaling Group max sizes"
    default = {}
}

variable "asg_min_sizes" {
    description = "Autoscaling Group min sizes"
    default = {}
}

variable "aws_access_key_id" {
    description = "AWS access key id"
    default = ""
}
variable "aws_secret_access_key" {
    description = "AWS secret access key"
    default = ""
}

variable "cloudflare_api_key" {
    description = "Cloudflare API key"
    default = ""
}
variable "cloudflare_email" {
    description = "Cloudflare email"
    default = ""
}
variable "cloudflare_zone_id" {
    description = "Cloudflare zone id"
    default = ""
}

variable "machine_storage_main" {
    type = number
    description = "Main storage id"
    default = 500
}
variable "machine_template_id_main" {
    description = "Main template id"
    default = "tpi7gqht" # tpi7gqht comes pre-installed with docker
}
variable "machine_type_main" {
    description = "Main machine type"
    default = "C5"
}

variable "machine_storage_worker_cpu" {
    type = number
    description = "CPU worker storage"
    default = 100
}
variable "machine_template_id_cpu" {
    description = "CPU template id"
    default = "tpi7gqht" # tpi7gqht comes pre-installed with docker
}

variable "machine_storage_worker_gpu" {
    type = number
    description = "GPU worker storage"
    default = 100
}
variable "machine_template_id_gpu" {
    description = "GPU template id"
    default = "tmun4o2g"
}

variable "rancher_api_url" {
    description = "Rancher API URL"
}
variable "rancher_access_key" {
    description = "Rancher access_key"
}
variable "rancher_secret_key" {
    description = "Rancher secret_key"
}

variable "region" {
    description = "Cloud region"
    default = "East Coast (NY2)"
}

variable "team_id" {
    description = "Cluster team id"
}

variable "team_id_integer" {
    description = "Cluster team id integer"
}

variable "workers" {
    type = list
    description = "Additional workers"
    default = []
}