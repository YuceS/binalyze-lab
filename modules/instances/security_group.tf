resource "aws_security_group" "server_sg" {
  name   = "${var.prefix} - AIR Server SG"
  vpc_id = var.vpc.id
}

resource "aws_security_group_rule" "server_out_all" {

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.server_sg.id
}
resource "aws_security_group_rule" "server_in_ssh_remote" {
  type              = "ingress"
  description       = "SSH Ingress Rule"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.response_body)}/32"]
  security_group_id = aws_security_group.server_sg.id
}

resource "aws_security_group_rule" "server_in_https_local" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.white_listed_cidrs != "" ? ["${chomp(data.http.myip.response_body)}/32", var.white_listed_cidrs] : ["${chomp(data.http.myip.response_body)}/32"]
  security_group_id = aws_security_group.server_sg.id
}

resource "aws_security_group_rule" "server_in_share_local" {
  type              = "ingress"
  from_port         = 9999
  to_port           = 9999
  protocol          = "tcp"
  cidr_blocks       = [var.vpc.cidr_block]
  security_group_id = aws_security_group.server_sg.id
}
resource "aws_security_group_rule" "server_in_all_local" {
  # Added for malware observation purposes
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = [var.vpc.cidr_block]
  security_group_id = aws_security_group.server_sg.id
}

resource "aws_security_group" "client_sg" {
  name   = "${var.prefix} - AIR Clients SG"
  vpc_id = var.vpc.id
}

resource "aws_security_group_rule" "client_in_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.response_body)}/32"]
  security_group_id = aws_security_group.client_sg.id


}

resource "aws_security_group_rule" "client_in_rdp" {
  type        = "ingress"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = var.white_listed_cidrs != "" ? ["${chomp(data.http.myip.response_body)}/32", var.white_listed_cidrs] : ["${chomp(data.http.myip.response_body)}/32"]

  security_group_id = aws_security_group.client_sg.id
}
resource "aws_security_group_rule" "client_in_any" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc.cidr_block]
  security_group_id = aws_security_group.client_sg.id
}


resource "aws_security_group_rule" "client_out_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.client_sg.id

}