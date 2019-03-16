/***
  Public Subnet
***/
resource "aws_subnet" "public_subnet" {
    count = "${length(var.public_subnet_cidr)}"
    vpc_id = "${aws_vpc.itca_vpc.id}"

    cidr_block = "${var.public_subnet_cidr[count.index]}"
    availability_zone = "${var.availability_zone_names[count.index]}"

    tags {
        Name = "ITCA Public Subnet AZ-${count.index + 1}"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = "${aws_vpc.itca_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.vpc_ig.id}"
    }

    tags {
        Name = "ITCA Public Subnet RT"
    }
}

resource "aws_route_table_association" "public_rta" {
    count = "${length(var.public_subnet_cidr)}"

    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.public_rt.*.id, count.index)}"
}

# /***
#   Private Subnet
# ***/
resource "aws_subnet" "private_subnet" {
    count = "${length(var.private_subnet_cidr)}"

    vpc_id = "${aws_vpc.itca_vpc.id}"

    cidr_block = "${var.private_subnet_cidr[count.index]}"
    availability_zone = "${var.availability_zone_names[count.index]}"

    tags {
        Name = "ITCA Private Subnet AZ-${count.index + 1}"
    }
}

resource "aws_route_table" "private_rt" {
    count = "${length(var.private_subnet_cidr)}"

    vpc_id = "${aws_vpc.itca_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${element(aws_instance.nat.*.id, count.index)}"
    }

    tags {
        Name = "ITCA Private Subnet RT AZ-${count.index + 1}"
    }
}

resource "aws_route_table_association" "private_rta" {
    count = "${length(var.private_subnet_cidr)}"

    subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.private_rt.*.id, count.index)}"
}

