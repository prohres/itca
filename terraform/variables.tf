variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "eu-central-1"
}

variable "availability_zone_names" {
    description = "AZs in this region to use"
    type    = "list"
    default = ["eu-central-1a", "eu-central-1b"]
}

# variable "count_az" {
#   default = "${length(var.availability_zone_names)}"
# }


variable "amis" {
    description = "AMIs by region"
    default = {
        eu-central-1 = "ami-05af84768964d3dc0" # Ubuntu Server 16.04 LTS (HVM), SSD Volume Type
    }
}

variable "itca_vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    type = "list"
    description = "Subnet CIDRs for public subnets"
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
    type = "list"
    description = "Subnet CIDRs for private subnets"
    default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "db_replication" {
    type = "list"
    description = "Setup master or slave replication"
    default = ["master", "slave"]
}

