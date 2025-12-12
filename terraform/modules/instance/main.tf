data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "wireguard_instance" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]

  iam_instance_profile = var.iam_instance_profile_name

  associate_public_ip_address = true

  user_data = file("${path.module}/wireguard-user-data.sh")

  tags = {
    Name = "MyVpn"
  }
}