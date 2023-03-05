variable "prefix" {}

variable "vpc_name" {
  description = "The VPC name"
  type        = string
  default     = "My VPC"

}
variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "The availability zones to use for subnets and resources in the VPC. By default, all AZs in the region will be used."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks to use for the public subnets."
  type        = list(string)
  default     = []
}

variable "create_internet_gateway" {
  description = "Optionaly create an Internet Gateway resource"
  type        = bool
  default     = true
}


variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type        = bool
  default     = false
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "tags" {
  type = map(any)
  default = {
    title = "Binalyze-AIR"

  }
}
