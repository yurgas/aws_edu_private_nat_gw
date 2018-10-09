# variable "aws_access_key" {}
# variable "aws_secret_key" {}

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_zone" {
  default = "eu-west-1a"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "172.16.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default = "172.16.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default = "172.16.1.0/24"
}

variable "host_ami" {
  # ubuntu 16.04 in eu-west-1
  default = "ami-0181f8d9b6f098ec4"
}

variable "ec2_host_type" {
  default = "t2.micro"
}

variable "ssh_key_name" {
  default = "mykey"
}

variable "ssh_pub_file" {
  default = "~/.ssh/id_rsa.pub"
}
