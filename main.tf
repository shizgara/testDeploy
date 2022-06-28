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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMLQPsk1ewvXL0LLMe8UlLqcCU3YWP7dYHTTw8T1QW2i8Sh369SMFgRO2vL3lkZgB++PEHpELgdn8Wty1Odng9nA0OGssn7t0fGc2/6a+OwQIHADIJr0/I9RcHFUFe+QpK01lRgZ9FFVT4UhkgKZ79tshMa6vMs/agmgQEz/k2prN1od2Ld03AauyB+N5KIWBJu5ZPDYh4P5aKlIL9vAP5QuOa4PZH7yh4S+RGzNgIDw42XRPad0JQnY3r3T8a0hD5Ckwp5lD7185Sad50Mm4ixozGr8a7oSC9+zOVJ2yPPFY/FPfBhyutUhtnz96hjmm3CTLxfJ+/ntPiY4OyLKywdSthTl36MmIXU35dAd4YxKwSQpHmqHxkoLxDKG/s6/sJ/59XK14nMjEUJ/YuDX9kBT/fciawEKlpRFh9DLgCSA8EUcrN0n8TU0oAgLyb29JAwS1bFtzlw++y573PryeAuutvtNDyOfEpF49Amo34ZTpaFcUm9xAj2E7HmwuHG7s= shizgara@ubuntu20"

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

output "public_ip_dev_server" {
  value = aws_instance.dev_server.public_ip
}

output "public_ip_prod_server" {
  value = aws_instance.prod_server.public_ip
}
