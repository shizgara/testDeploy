provider "aws" {
    region = "eu-central-1"
    profile = var.profile
}


resource "aws_instance" "rmq" {
    ami = "ami-0c9354388bb36c088"
    instance_type = "t2.micro"
    key_name = "testpipline"
    vpc_security_group_ids = ["sg-0718131af947423c2"]

    tags = {
      Name = var.name
      group = var.group
    }
  
}