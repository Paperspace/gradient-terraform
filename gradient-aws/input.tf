variable "aws_certificate_arn" {
    description = "AWS certificate ARN"
    default = ""
}

variable "aws_region" {
    description = "AWS region"
    default = "us-east-1"
}

variable "availability_zone_count" {
    description = "Number of availability zones to be used"
    default = 2
}

variable "cidr" {
    description = "CIDR network block for VPC"
    default = "10.0.0.0/16"
}

variable "iam_accounts" {
    description = "Additional AWS account numbers to add to the aws-auth configmap."
    type        = list(string)

    default = []
}

variable "iam_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "iam_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
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

variable "k8s_security_group_ids" {
    description = "List of security group ids for kubernetes nodes (comma delimited)"
    default = ""
}

variable "k8s_subnet_ids" {
    description = "k8s node subnet ids"
    default = ""
}

variable "subnet_netmask" {
    description = "Netmask used for subnet creation"
    default = "18"
}