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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpoxR5qNe9+OPHcmwsslPFHEkaRAzywKLxWJ96c+P+rHuzMvnDkjCj3qgP2ah45cvhdhSg72+UYhvq64AOQtD9d6YMYNlgiu0OVuY8SZjPiI85kPAqXb9RnFlkMziBM1mggqYUxqC/gjr0ChEeZ0C/KVm3e8uYy6U7+UpSxmsf+f2W9py0lfusyCpAUM5aKrm7UUEftU90brIRW0iYw9n7Vf92ZPqrV5VKeDOUr3uzbGBk7yXIY6RAeeIxUp6kstIuiW/cr6rAJJdsoZeKqe2XTiNeX4cUuyDs59pf8fVL2v7ymnSPeMa8lkImv7+cITBq3UH2JOocuLICQAfOPAk/ WebServer"

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
