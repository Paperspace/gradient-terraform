variable "become_ssh_user" {
    description = "Remote ssh user with elevated privileges"
    default = "root"
}

variable "k8s_master_node" {
    type = map
    description = "Kubernetes master node"
}

variable "k8s_workers" {
    type = list
    description = "Kubernetes workers"
}

variable "ssh_key" {
    description = "SSH key_path"
    default = ""
}

variable "ssh_key_path" {
    description = "SSH key_path"
    default = "~/.ssh/id_rsa"
}

variable "ssh_user" {
    description = "SSH user"
    default = "ubuntu"
}

variable "cpu_selector" {
    description = "Node CPU selector"
    default = "metal-cpu"
}
variable "gpu_selector" {
    description = "Node GPU selector"
    default = "metal-gpu"
}

variable "local_storage_path" {
    description = "Local storage path on nodes"
    default = "/tmp/gradient"
}

variable "local_storage_server" {
    description = "Local storage server"
    default = ""
}

variable "local_storage_type" {
    description = "Local storage type"
    default = "HostPath"
}

variable "setup_docker" {
    description = "Setup docker"
    default = false
}

variable "setup_nvidia" {
    description = "Setup NVIDIA Cuda drivers, docker, and kubernetes integrations (Requires reboot)"
    default = false
}

variable "service_pool_name" {
    description = "Service node selector"
    default = "services-small"
}

variable "use_pod_anti_affinity" {
    description = "Use pod anti-affinity"
    default = false
}