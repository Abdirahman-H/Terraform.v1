output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_ids" {
  value = [for key, subnet in aws_subnet.subnets : subnet.id if startswith(key, "public")]
}

output "private_subnet_ids" {
  value = [for key, subnet in aws_subnet.subnets : subnet.id if startswith(key, "private")]
}


