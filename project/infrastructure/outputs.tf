output "instance_ip" {
  description = "IP address of the EC2 instance"
  value       = module.compute.public_ip
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.load_balancer.dns_name
}

output "rds_endpoint" {
  description = "rds endpoint"
  value       = module.database.rds_endpoint
}
