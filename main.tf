provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}


# Create elastic IP
resource "aws_eip" "static_ip_dev" {
  instance = aws_instance.dev_server.id
}
resource "aws_eip" "static_ip_prod" {
  instance = aws_instance.prod_server.id
}


# Create instances
resource "aws_instance" "dev_server" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "id_rsa"
  vpc_security_group_ids = [aws_security_group.webserver.id]
  tags = {
    Name    = "Dev_Server"
    Owner   = "Shizgara"
    Project = "Simple Website"
    }
}

resource "aws_instance" "prod_server" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "id_rsa"
  vpc_security_group_ids = [aws_security_group.webserver.id]
  tags = {
    Name    = "Prod_Server"
    Owner   = "Shizgara"
    Project = "Simple Website"
  }
}


# Create key-pair
resource "aws_key_pair" "project" {
  key_name   = "id_rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjAP8SptD87vL8B+pkHH8muxhAny2+jRPJ0vgb/rJ5Bz+qSXPEH+HLHFlg5GOtYNq8P43GdeNEns0wUImjanAaJZhAf7J8EDqDSMv4O3/9Vi4EUemqSp5PimWPiNiY/FKLkEOKOR77vhRZgcA6fRPvsZOf5brAAlVvgds64P9pj56UhXuNV8OdgCoVf9YfS/ZXpDr2csu2KuZWUTkmoZmoQ6euMZXhKceT3XLJbZTitiu803wnSnEPu30YE6ZJ77zkqDR/LcWGtJ7GtivPqFzcGRZyx03aZMxPRjDKuX5UA54rEPE+XVz9Id0/NeD3rLRA+hzL2AN0NcR/RunXldiYhuwkfHxKGN7iCrHJMrbjC1R6dDTr14+8idHC6sO2wsjxAXRXu7DdMecojOfsx9T/Lqecb8dilfrYLrLoNtQWhFosgUVvg53TQ3m5P1zKMAlkAbc4Z4NMrGEIGmRhmnuI9JFx515jF6BoEjS/zu9bOP43OBZZeRn3JpzSwAj1M0X/XRQctGaAplZdrSMCS03WSDJQQBzO1j64HdTaJVIunzc3k1GX5h2YiaLxZJzvS7WhpMoUsqwQEnFL3Ugx6swj21rD7NNA70fbNpt7Q0JWEipEG33H0p0NjTihZSxj6kz+4JUsXRJDCXsbSzMdoiwriXFfnEK+9mROPz9DYZ+IuQ== ubuntu@ip-172-31-45-54"

}

# Create Security Group
resource "aws_security_group" "webserver" {
  name        = "websec"
  description = "dyn_security"
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = ["80", "443", "8080", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "sec_group"
  }
}


# Output public ip
output "dev_server_ip" {
  value = aws_eip.static_ip_dev.public_ip
}
output "prod_server_ip" {
  value = aws_eip.static_ip_prod.public_ip
}

#output "public_ip_dev_server" {
#  value = aws_instance.dev_server.public_ip
#}

#output "public_ip_prod_server" {
#  value = aws_instance.prod_server.public_ip
#}
