resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "key_pair" {
  key_name   = format("%s-%s", "binalyze-lab-key-pair", formatdate("YYYYMMDDhhmmss", timestamp()))
  public_key = tls_private_key.key_pair.public_key_openssh
  lifecycle {
    ignore_changes = [
      key_name,
    ]
  }

}
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem

}


resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "${var.prefix}-s3-access"
  assume_role_policy = file("${path.module}/files/user-data/assumerolepolicy.json")
}
resource "aws_iam_policy" "policy" {
  name = "${var.prefix}-policy"
  policy = templatefile("${path.module}/files/user-data/policys3bucket.json",
    { BucketName = aws_s3_bucket.evidences.id }
  )
}


resource "aws_iam_policy_attachment" "attachment" {
  name               = "${var.prefix}-s3access-attach"
  roles      = ["${aws_iam_role.ec2_s3_access_role.name}"]
  policy_arn = aws_iam_policy.policy.arn
}
resource "aws_iam_instance_profile" "air_server" {
  name               = "${var.prefix}-s3-access"
  role = "${aws_iam_role.ec2_s3_access_role.name}"
}
resource "aws_s3_bucket" "evidences" {
  bucket              = format("%s-%s", "${var.prefix}-evidences", formatdate("YYYYMMDDhhmmss", timestamp()))
  object_lock_enabled = true
  force_destroy       = true
  acl    = "private"
  lifecycle {
    ignore_changes = [bucket]
  }
  tags = merge(
    var.tags,
    {
  
      Definition = "${var.prefix}"

    },
  )
}
resource "aws_instance" "air_server" {
  ami                         = data.aws_ami.debian_11.id
  instance_type               = var.server_size
  subnet_id                   = var.server_subnet.id
  vpc_security_group_ids      = [aws_security_group.server_sg.id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.key_pair.key_name
  user_data                   = file("${path.module}/files/user-data/air-console.sh")
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.air_server.name
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name       = "Binalyze-AIR-SERVER"
    Definition = "${var.prefix}"
  }
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_instance" "win_clients" {
  for_each                    = { for ins in local.instances : ins.name => ins }
  ami                         = contains(["2012"], "${each.value.prefix}") ? data.aws_ami.windows_2012.id : data.aws_ami.windows_2022.id
  instance_type               = each.value.instance_type
  subnet_id                   = var.client_subnet.id
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.client_sg.id]
  associate_public_ip_address = var.expose_clients
  user_data = templatefile("${path.module}/files/user-data/${each.value.user_data}",
    {
      ServerName = aws_instance.air_server.private_dns,
      HostName   = "${each.value.name}"
  })
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.air_server.name
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name       = "${each.value.name}"
    Definition = "${var.prefix}"
  }
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    time_sleep.wait_for_air_server
  ]

}

resource "aws_instance" "linux_clients" {
  for_each                    = { for ins in local.linux_instances : ins.name => ins }
  ami                         = data.aws_ami.ubuntu_20.id
  instance_type               = each.value.instance_type
  subnet_id                   = var.client_subnet.id
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.client_sg.id]
  associate_public_ip_address = var.expose_clients
  user_data = templatefile("${path.module}/files/user-data/${each.value.user_data}",
    {
      ServerName = aws_instance.air_server.private_dns,
      HostName   = "${each.value.name}"
  })
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.air_server.name
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name       = "${each.value.name}"
    Definition = "${var.prefix}"
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    time_sleep.wait_for_air_server
  ]
}

resource "aws_instance" "custom_clients" {
  for_each                    = { for ins in local.custom_instances : ins.name => ins }
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = var.client_subnet.id
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.client_sg.id]
  associate_public_ip_address = var.expose_clients
  user_data = templatefile("${path.module}/files/user-data/${each.value.user_data}",
    {
      ServerName = aws_instance.air_server.private_dns,
      HostName   = "${each.value.name}"
  })
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.air_server.name
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name       = "${each.value.name}"
    Definition = "${var.prefix}"
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    time_sleep.wait_for_air_server
  ]
}

resource "time_sleep" "wait_for_air_server" {
  create_duration = "120s"

  depends_on = [aws_instance.air_server]
}
