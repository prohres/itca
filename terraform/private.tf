/***
  Database Servers
***/
resource "aws_security_group" "db_sg" {
    name = "itca-vpc_db"
    description = "Allow incoming database connections."

    ingress { # SQL Server
        from_port = 1433
        to_port = 1433
        protocol = "tcp"
        security_groups = ["${aws_security_group.web_sg.id}"]
    }
    ingress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = ["${aws_security_group.web_sg.id}"]
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
        cidr_blocks = ["${var.itca_vpc_cidr}"]
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

    vpc_id = "${aws_vpc.itca_vpc.id}"

    tags {
        Name = "ITCA DBServer SG"
    }
}

resource "aws_instance" "db" {
    count = "${length(var.availability_zone_names)}"

    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "${var.availability_zone_names[count.index]}"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.db_sg.id}"]
    subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
    source_dest_check = false

    tags {
        Name = "ITCA DB Server-${var.db_replication[count.index]}"
    }
}