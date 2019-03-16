/***
  VPC
***/
resource "aws_vpc" "itca_vpc" {
    cidr_block = "${var.itca_vpc_cidr}"
    enable_dns_hostnames = true

    tags {
        Name = "ITCA VPC"
    }
}

resource "aws_internet_gateway" "vpc_ig" {
    vpc_id = "${aws_vpc.itca_vpc.id}"
  
    tags {
        Name = "ITCA IG"
    }
}

/***
  NAT Instance
***/
resource "aws_security_group" "nat_sg" {
    name = "nat-sg"
    description = "Allow traffic to pass from the private subnet to the internet"
    
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.itca_vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.itca_vpc.id}"

    tags {
        Name = "ITCA NAT SG"
    }
}

resource "aws_instance" "nat" {
    count = "${length(var.public_subnet_cidr)}"
    
    ami = "ami-0097b5eb" # amzn-ami-vpc-nat-hvm-2018.03.0.20180508-x86_64-ebs
    availability_zone = "${var.availability_zone_names[count.index]}"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat_sg.id}"]
    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "ITCA NAT AZ-${count.index + 1}"
    }
}

resource "aws_eip" "nat_eip" {
    count = "${length(var.public_subnet_cidr)}"

    instance = "${element(aws_instance.nat.*.id, count.index)}"
    vpc = true

    tags {
        Name = "ITCA NAT EIP AZ-${count.index + 1}"
    }
}


