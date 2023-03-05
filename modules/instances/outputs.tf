output "server_public_ip" {
  value = aws_instance.air_server.public_ip
}
output "server_local_address" {
  value = aws_instance.air_server.private_dns
}
output "windows_clients_list" {
  value = { for w in aws_instance.win_clients : w.tags.Name => "local address: ${w.private_ip}, public address: ${w.public_ip}"
  }
}
output "linux_clients_list" {
  value = { for w in aws_instance.linux_clients : w.tags.Name => "local address: ${w.private_ip}, public address: ${w.public_ip}"
  }
}
output "custom_clients_list" {
  value = { for w in aws_instance.custom_clients : w.tags.Name => "local address: ${w.private_ip}, public address: ${w.public_ip}"
  }
}
