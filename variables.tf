variable "aws_region" {
  description = "The aws region "
  default = "eu-central-1"
}

variable "key_name" {
  description = "SSH keys to connect to ec2 insctance"
  default = "testpipline"
}

variable "instance_type" {
  description = "Instance type for ec2"
  default = "t2.micro"
}

variable "security_group" {
  description = "Name of Security group"
  default = "my_security_group_for_ec2"
}

variable "tag_name" {
  description = "Tag Name of for ec2  inctance"
  default = "my_ec2_instance"
}

variable "ami_id" {
  description = "AMI for Ubuntu ec2 instance"
  default = "ami-0c9354388bb36c088"
}