locals {
  winclients = [
    for c in var.win_clients : [
      for i in range(1, c.number + 1) : {
        name          = "${c.prefix}-${i}"
        instance_type = c.size
        user_data     = "win-client.ps1"
        prefix        = c.prefix
      }
    ]
  ]
  linuxclients = [
    for c in var.linux_clients : [
      for i in range(1, c.number + 1) : {
        name          = "${c.prefix}-${i}"
        instance_type = c.size
        user_data     = "linux-client.sh"
        prefix        = c.prefix
      }
    ]
  ]

  customclients = [
    for c in var.custom_clients : [
      for i in range(1, c.number + 1) : {
        name          = "${c.prefix}-${i}"
        instance_type = c.size
        user_data     = "${c.win ? "win-client.ps1" : "linux-client.sh"}"
        win           = c.win
        ami           = c.custom_ami
        prefix        = c.prefix
      }
    ]
  ]

}

locals {
  instances        = flatten(local.winclients)
  linux_instances  = flatten(local.linuxclients)
  custom_instances = flatten(local.customclients)
}



