variable "availability_zone_count" {
    type = number
}

variable "enable" {
    type = bool
    description = "If module should be enabled"
}

variable "cidr" {
    description = "CIDR network block for VPC"
}

variable "name" {
    description = "Name"
}

variable "private_subnet_tags" {
    type = map
    description = "Private subnet tags"
}

variable "public_subnet_tags" {
    type = map
    description = "Public subnet tags"
}

variable "subnet_netmask" {
    description = "Netmask used for subnet creation"
}

variable "vpc_tags" {
    type = map
    description = "Vpc tags"
}