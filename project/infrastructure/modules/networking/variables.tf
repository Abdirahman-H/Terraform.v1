variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}
