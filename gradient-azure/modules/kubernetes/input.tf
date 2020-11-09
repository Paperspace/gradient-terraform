variable "name" {
    description = "Name"
}

variable "enable" {
    type = bool
    description = "If module should be enabled"
}

variable "kubeconfig_path" {
    description = "Kubeconfig output path"
}

variable "node_asg_max_sizes" {
    description = "Node auto scaling group max sizes"
}

variable "node_asg_min_sizes" {
    description = "Node auto scaling group min sizes"
}

variable "node_instance_types" {
    description = "Node instance type"
}

variable "k8s_version" {
    description = "Kubernetes version"
}

variable "vpc_id" {
    description = "VPC id"
}

variable "write_kubeconfig" {
    description = "Write kubeconfig to a file"
}