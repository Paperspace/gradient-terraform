variable "azure_location" {
    description = "Azure Location"
    default = "eastus"
}

variable "azure_resource_group_name" {
  description = "Azure Resource Group Name"
}

variable "k8s_node_asg_max_sizes" {
    description = "k8s node autoscaling group maximum sizes"
    default = {}
}

variable "k8s_node_asg_min_sizes" {
    description = "k8s node autoscaling group minimum sizes"
    default = {}
}

variable "k8s_node_instance_types" {
    description = "k8s node instance types"
    default = {}
}