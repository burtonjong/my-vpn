resource "aws_security_group" "wireguard_sg" {
  name        = "wireguard_sg"
  description = "Security group for wireguard_sg"

  vpc_id = var.vpc_id

  # Allow inbound on Wireguards default port
  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"] # Anyone can connect I think
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyVpn"
  }
}