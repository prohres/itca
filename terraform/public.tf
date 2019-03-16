/***
  Web Servers
***/
resource "aws_security_group" "web_sg" {
    name = "web-sg"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.itca_vpc_cidr}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress { # SQL Server
        from_port = 1433
        to_port = 1433
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    egress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }

    vpc_id = "${aws_vpc.itca_vpc.id}"

    tags {
        Name = "ITCA WebServer SG"
    }
}

resource "aws_instance" "web" {
    count = "${length(var.availability_zone_names)}"

    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "${var.availability_zone_names[count.index]}"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.web_sg.id}"]
    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "ITCA WebServer-${count.index + 1}"
    }
}

resource "aws_eip" "web_eip" {
    count = "${length(var.public_subnet_cidr)}"

    instance = "${element(aws_instance.web.*.id, count.index)}"
    vpc = true

    tags {
        Name = "ITCA WebServer EIP AZ-${count.index + 1}"
    }
}
