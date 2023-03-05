cidr_block = "10.100.0.0/16"
az = [
  "eu-west-2a",
  "eu-west-2b",
  "eu-west-2c",
]
public_cidrs = [
  "10.100.0.0/20",
]
fqdn_enable = true
vpc         = "Binalyze Lab VPC"
prefix      = "binalyze-lab"
server_type = "t3.xlarge"
wins = [{
  number = 1
  prefix = "windows2022"
  size   = "t3.medium"
  },
  {
    number = 1
    prefix = "windows2012"
    size   = "t3.medium"
}]
linux_clients = [
  {
    number = 1
    prefix = "ubuntu20"
    size   = "t3.medium"
}]
custom_clients = [
  {
    custom_ami = "ami-00950d2c99bfd49a6"
    number     = 1
    prefix     = "custom"
    size       = "t3.medium"
    win        = false
}]
