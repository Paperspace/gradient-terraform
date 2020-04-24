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

variable "availability_zone_count" {
    description = "Number of availability zones to be used"
    default = 2
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

variable "gradient_processing_chart" {
    description = "Gradient processing chart"
    default = "gradient-processing"
}

variable "kubeconfig_path" {
    description = "Kubeconfig path"
    default = "./gradient-kubeconfig"
}

variable "name" {
    description = "Name"
}

variable "public_key_path" {
    description = "Login key path"
    default = ""
}

variable "sentry_dsn" {
    description = "DSN for sentry alerts"
    default = ""
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


# Helm
variable "k8s_endpoint" {
    description = "Kubernetes endpoint (https://k8s_endpoint:6443)"
    default = ""
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

variable "k8s_version" {
    description = "Kubernetes version"
    default = "1.14"
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

# Network
variable "cidr" {
    description = "CIDR network block for VPC"
    default = "10.0.0.0/16"
}

variable "subnet_netmask" {
    description = "Netmask used for subnet creation"
    default = "24"
}

# Storage
variable "shared_storage_server" {
    description = "Shared storage server to be used for Gradient"
    default = ""
}
variable "shared_storage_path" {
    description = "Shared storage path to be used for Gradient"
    default = "/"
}
variable "shared_storage_type" {
    description = "Shared storage type"
    default = "efs"
}

# AWS
variable "aws_region" {
    description = "AWS region"
    default = "us-east-1"
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