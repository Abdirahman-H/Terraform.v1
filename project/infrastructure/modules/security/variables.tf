variable "vpc_id" {
  description = "VPC ID to attach security groups to"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "82.9.238.42/32"
}

