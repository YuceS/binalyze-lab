module "network" {
  source             = "../../modules/network"  
  cidr_block           = var.cidr_block
  availability_zones   = var.az
  public_subnet_cidrs  = var.public_cidrs
  enable_dns_hostnames = var.fqdn_enable
  vpc_name             = var.vpc
  prefix          = var.prefix
}
module "compute" {
 // source             = "git::https://github.com/YuceS/binalyze-lab.git//modules/instances"
  source             = "../../modules/instances"  
  vpc                = module.network.vpc
  expose_clients     = true
  expose_server      = true
  client_subnet      = module.network.public_subnet
  server_subnet      = module.network.public_subnet
  white_listed_cidrs = ""
  prefix        = var.prefix
  win_clients        = var.wins
  linux_clients      = var.linux_clients
  custom_clients     = var.custom_clients
  server_size        = var.server_type
}
