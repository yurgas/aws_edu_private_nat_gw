provider "aws" {
  # access_key = "${var.aws_access_key}"
  # secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "edu-nat VPC"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "edu-nat Internet gw"
  }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.aws_zone}"

  tags {
    Name = "edu-nat Public subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "${var.aws_zone}"

  tags {
    Name = "edu-nat Private subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "edu-nat routetable public net"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "nat" {
  vpc        = true
  depends_on = ["aws_internet_gateway.default"]

  tags {
    Name = "edu-nat nat-gw ip"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"

  tags {
    Name = "edu-nat nat-gw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    Name = "edu-nat routetable private net"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_key_pair" "default" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${file(var.ssh_pub_file)}"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public_host" {
  ami = "${var.host_ami}"
  instance_type = "${var.ec2_host_type}"
  key_name = "${var.ssh_key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  subnet_id = "${aws_subnet.public.id}"

  tags {
    Name = "edu-nat public host"
  }

  root_block_device {
    volume_size = "10"
  }
}

resource "aws_eip" "public_host" {
  instance   = "${aws_instance.public_host.id}"
  vpc        = true
  depends_on = ["aws_internet_gateway.default"]

  tags {
    Name = "edu-nat public_host ip"
  }
}

output "public_host_ip" {
  value = "${aws_eip.public_host.public_ip}"
}

resource "aws_instance" "private_host" {
  ami = "${var.host_ami}"
  instance_type = "${var.ec2_host_type}"
  key_name = "${var.ssh_key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  subnet_id = "${aws_subnet.private.id}"

  tags {
    Name = "edu-nat private host"
  }

  root_block_device {
    volume_size = "10"
  }
}

output "private_host_ip" {
  value = "${aws_instance.private_host.private_ip}"
}
