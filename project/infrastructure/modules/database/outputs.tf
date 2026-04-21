output "rds_endpoint" {
  description = "the endpoint of the rds"
  value       = aws_db_instance.my_db_instance.endpoint
}
