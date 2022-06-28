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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyuTRO+Q0LLu3KYUSVG2sfi+fv/tKPkZBxb5UFIy1JG700+XeNHCjLlbIAap5EAYdv7L8sPdzFbDfX3LVSePWIMZi1f27TXP1g3qacqS5Be5rCg2aI/uQQ++bwtNh3UvqEpWgWQLQy9g9i/iwvIdvbibmBPEWwdbE856o/4bmFXAoLaamXQUKPvr1uMqOchZ8Sy6AmDGjLsAUmpaRS5wAO8hM/34fVICtN8RQjIErpDToznehKdzVW4dtokObOoX0qOSH8RJiSe/V2ldQRuiTIr+LrTmcDB8wHyb81AX2zzYBzJwWokz6Rj5McT5keOUDgvheVuCik7MTvoymr4Or3+vRykSRdBJaLZehv6T/1NfM4nZxBucbsHx3vI1G0aXllQSy3Z2Kvadu+NbWox7KitpqYI9zdH5DC3F2/mTS1FJDh3sWBzbbCtSUmldiP1K8qfGS7rUFV324V+AoXJoQBWyoo6JujNo7IojTAEiJYnnhCTfj2eTSx3UcwxpY19nc= ubuntu@ip-172-31-34-0"

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
