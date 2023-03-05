variable "vpc" {

}

variable "expose_clients" {
  type    = bool
  default = false
}

variable "white_listed_cidrs" {}
variable "win_clients" {
  type = set(object({
    number = number
    size   = string
    prefix = string
  }))
  default = [{
    number = 1
    prefix = "2022"
    size   = "t3.xlarge"

  }]
}

variable "linux_clients" {
  type = set(object({
    number = number
    size   = string
    prefix = string
  }))
  default = [{
    number = 1
    prefix = "ubuntu-20"
    size   = "t3.xlarge"
  }]

}

variable "custom_clients" {
  type = set(object({
    number     = number
    custom_ami = string
    size       = string
    prefix     = string
    win        = bool
  }))
  default = [{
    number     = 1
    custom_ami = "ami-01dfbe7e4a7c6561d"
    prefix     = "custom"
    size       = "t3.xlarge"
    win        = false
  }]

}
variable "lab_mode" {
  description = "One of 3 deployment modes must be chosen - public, private, hybrid"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private", "hybrid"], var.lab_mode)
    error_message = "deployment mode can opnly be one of three options - public, private, hybrid"
  }

}
variable "server_size" {
  description = "The Binalyze AIR server"
  type        = string
  default     = "t3.xlarge"

}
variable "tags" {
  type = map(any)
  default = {
    title     = "Binalyze-AIR"
    terraform = "true"

  }
}
variable "prefix" {}

variable "expose_server" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}

variable "root_volume_size" {
  type    = number
  default = 40
}
variable "root_volume_type" {
  type    = string
  default = "gp2"
}
variable "server_subnet" {}
variable "client_subnet" {}

