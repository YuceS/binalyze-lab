variable "cidr_block" {}
variable "az" {}
variable "public_cidrs" {}
variable "fqdn_enable" {}
variable "server_type" {}
variable "custom_clients" {}
variable "linux_clients" {}
variable "wins" {}
variable "prefix" {}
variable "vpc" {}
variable "tags" {
  type = map(any)
  default = {
    title = "Binalyze-AIR"

  }
}
