module "compute" {
  source             = "./modules/compute"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  subnet_id          = module.networking.public_subnet_ids[0]
  security_group_ids = [module.security.ec2_sg_id]
  key_name           = data.aws_key_pair.keypair_ssh.key_name
}


module "database" {
  source             = "./modules/database"
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [module.security.rds_sg_id]
  db_username        = var.db_username
  db_password        = var.db_password

}



resource "aws_lb" "load_balancer" {
  name               = "lb-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security.alb_sg_id]
  subnets            = [module.networking.public_subnet_ids[0], module.networking.public_subnet_ids[1]]

  tags = merge(local.tags, {
    Name = "lb"
  })
}




resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-tg-${terraform.workspace}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.networking.vpc_id
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
  target_id        = module.compute.instance_id
  port             = 80
}


module "networking" {
  source = "./modules/networking"

  vpc_cidr = var.vpc_cidr
  subnets  = var.subnets
}


module "security" {
  source   = "./modules/security"
  vpc_id   = module.networking.vpc_id
  ssh_cidr = var.ssh_cidr
}
