variable "become_ssh_user" {
    description = "Remote ssh user with elevated privileges"
    default = "root"
}

variable "k8s_endpoint" {
    description = "Kubernetes endpoint (https://k8s_endpoint:6443)"
    default = ""
}

variable "k8s_master_ips" {
    type = list
    description = "Kubernetes master ips"
}

variable "k8s_workers" {
    type = list
    description = "Kubernetes workers"
}

variable "k8s_version" {
    description = "Kubernetes version"
    default = "1.15.11"
}

variable "kubeconfig_path" {
    description = "Kubeconfig path"
    default = "./gradient-kubeconfig"
}

variable "name" {
    description = "Name"
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


# Global

variable "amqp_hostname" {
    description = "AMQP hostname"
    default = "broker.paperspace.io"
}

variable "amqp_port" {
    description = "AMQP port"
    default = "5672"
}
variable "amqp_protocol" {
    description = "AMQP protocol"
    default = "amqps"
}

variable "cluster_apikey" {
    description = "Gradient cluster API key"
}
variable "cluster_handle" {
    description = "Gradient cluster API handle"
}

variable "domain" {
    description = "Domain used to host gradient"
}

variable "global_selector" {
    description = "Node selector prefix used globally"
    default = ""
}

variable "gradient_processing_chart" {
    description = "Gradient processing chart"
    default = "gradient-processing"
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

variable "sentry_dsn" {
    description = "DSN for sentry alerts"
    default = ""
}

variable "service_pool_name" {
    description = "Service node selector"
    default = "services-small"
}

# Gradient
variable "artifacts_access_key_id" {
    description = "S3 compatibile access key for artifacts object storage"
}

variable "artifacts_object_storage_endpoint" {
    description = "Object storage endpoint to be used for Gradient"
    default = ""
}

variable "artifacts_path" { 
    description = "Object storage path used for Gradient"
}
variable "artifacts_secret_access_key" {
    description = "S3 compatible access key for artifacts object storage"
}
variable "gradient_processing_version" {
    description = "Gradient processing version"
    default = "*"
}
variable "logs_host" {
    description = "Logs host"
    default = "logs.paperspace.io"
}

# LB
variable "tls_cert" {
    description = "SSL certificate used for loadbalancers"
    default = ""
}
variable "tls_key" {
    description = "SSL key used for loadbalancers"
    default = ""
}

# Storage

variable "shared_storage_path" {
    description = "Shared storage path"
    default = "/"
}
variable "shared_storage_server" {
    description = "Shared storage server"
    default = ""
}
variable "shared_storage_type" {
    description = "Shared storage type"
    default = "nfs"
}

variable "use_pod_anti_affinity" {
    description = "Use pod anti-affinity"
    default = false
}