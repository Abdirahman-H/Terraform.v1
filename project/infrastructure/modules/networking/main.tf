
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
}


resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id = aws_vpc.my_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}



resource "aws_route_table_association" "rt_1" {
  subnet_id      = aws_subnet.subnets["public_subnet1"].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "rt_2" {
  subnet_id      = aws_subnet.subnets["public_subnet2"].id
  route_table_id = aws_route_table.public.id
}



resource "aws_eip" "elastic_ip" {
  domain = "vpc"
}


resource "aws_nat_gateway" "nat_gtw" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.subnets["public_subnet1"].id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gtw.id
  }
}


resource "aws_route_table_association" "private_rt_1" {
  subnet_id      = aws_subnet.subnets["private_subnet1"].id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "private_rt_2" {
  subnet_id      = aws_subnet.subnets["private_subnet2"].id
  route_table_id = aws_route_table.private.id
}
