resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "my_vpc"
  }
}


resource "aws_subnet" "my_private_subnet1" {
  availability_zone = var.first_az
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet1_cidr

  tags = {
    Name = "private_subnet1"
  }
}


resource "aws_subnet" "my_public_subnet1" {
  availability_zone = var.first_az
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet1_cidr

  tags = {
    Name = "public_subnet1"
  }
}


resource "aws_subnet" "my_private_subnet2" {
  availability_zone = var.second_az
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet2_cidr

  tags = {
    Name = "private_subnet2"
  }
}


resource "aws_subnet" "my_public_subnet2" {
  availability_zone = var.second_az
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet2_cidr

  tags = {
    Name = "public_subnet2"
  }
}











resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "igw"
  }
}



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}



resource "aws_route_table_association" "rt_1" {
  subnet_id      = aws_subnet.my_public_subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "rt_2" {
  subnet_id      = aws_subnet.my_public_subnet2.id
  route_table_id = aws_route_table.public.id
}



resource "aws_eip" "elastic_ip" {
  domain = "vpc"
}


resource "aws_nat_gateway" "nat_gtw" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.my_public_subnet1.id

  tags = {
    Name = "gw NAT"
  }
}








resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gtw.id
  }

  tags = {
    Name = "private"
  }
}


resource "aws_route_table_association" "private_rt_1" {
  subnet_id      = aws_subnet.my_private_subnet1.id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "private_rt_2" {
  subnet_id      = aws_subnet.my_private_subnet2.id
  route_table_id = aws_route_table.private.id
}





resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.9.238.42/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





resource "aws_security_group" "rds_sg" {
  name   = "ec2-rds-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_instance" "ec2_instance" {
  ami                         = "ami-061e1ade216078a11"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.my_public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = "keypair-wordpress"

  tags = {
    Name = "ec2-wordpress"
  }
}



resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.my_private_subnet1.id, aws_subnet.my_private_subnet2.id]
}


resource "aws_db_instance" "my_db_instance" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
}





resource "aws_security_group" "alb_sg" {
  name   = "ec2-alb-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_lb" "load_balancer" {
  name               = "lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.my_public_subnet1.id, aws_subnet.my_public_subnet2.id]

  tags = {
    Environment = "production"
  }
}




resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}




resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}


resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.ec2_instance.id
  port             = 80
}




