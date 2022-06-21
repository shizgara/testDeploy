provider "aws" {
    region = var.aws_region  
}

# Create security group

resource "aws_security_group" "my_security_group" {
  name = var.security_group
  description = "security group for ec2 insctance"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outbound from jenkins
  egress {
    from_port = 0
    to_port = 65635
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group
  }
}

# Create AWS ec2 instance

resource "aws_instance" "myFirstInstance" {
    ami = var.ami_id
    key_name = var.key_name
    instance_type = var.insctance_type
    security_groups = [var.security_group]
    tags = {
      Name = var.tag_name
    }
}

# Create Elastic IP address
resource "aws_eip" "myFirstInstance" {
  vpc = true
  instance = aws_instance.myFirstInstance.id
  tags = {
    Name = "my_elastic_ip"
  }
}