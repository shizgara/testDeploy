provider "aws" {
  region = "eu-central-1"
}


resource "aws_eip" "static_ip" {
  instance = aws_instance.project_serv[0].id
}
resource "aws_eip" "static_ip_1" {
  instance = aws_instance.project_serv[1].id
}


resource "aws_instance" "project_serv" {
  count         = 2
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"

  key_name               = "id_rsa"
  availability_zone      = "eu-central-1"
  vpc_security_group_ids = [aws_security_group.webserver.id]

}


resource "aws_key_pair" "project" {
  key_name   = "id_rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnrMGyvMoOmAlRKTMRR+/G+PB2W9Fz6VEFMbpgplIToiWn3NgUKse5WFFIfWy2NjRFz04Foav2H/ssSpEcbrV1lMniGu3QKlyXM/6tcqCEZLcfAUggoUb/qXEyBbRSP8OvOZxqr41+i7687GPgAORlrez3K2KLF2nfTv565dqk2oVT6qwUOv5AUbPdD/JJO9KmaqOTBmCsBP9MLR2kRPUp2S2uNJBNab+4cMzApCVoXXvdbCu557steHYQvA8xHzN+R2TIi5DMjq/j2GwOzVpXtEinyl5Fpku/YtKqYhJQVPp1zeB9/o5TesvRzg/9k5U2joWq+zwt5tX/kwH5p775JU/47DAPDyb0dm8KrHKZs0rEjmUxirGx3R+VimVwKUopMNcuh06DC3AczlCLy2LOkSQup+VU637T4qM629+HdRleilcwGy6z0iiaqZRqQGQEgNXYSjFXqaztA+BUtdG70VkHBu4DNH6T9SncLtW409MDuVP6rLz3TtKG7A97/40= shizgara@shizgaraUbuntu"

}
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



output "test_server_ip" {
  value = aws_instance.project_serv[1].public_ip
}
output "prod_server_ip" {
  value = aws_instance.project_serv[0].public_ip
}
