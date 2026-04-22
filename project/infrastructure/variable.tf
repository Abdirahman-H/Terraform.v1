variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}


variable "region" {
  description = "The AWS region to deploy all resources in"
  type        = string
  default     = "eu-west-2"
}



variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}


variable "subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    private_subnet1 = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "eu-west-2a"
    }
    public_subnet1 = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "eu-west-2a"
    }
    private_subnet2 = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "eu-west-2b"
    }
    public_subnet2 = {
      cidr_block        = "10.0.4.0/24"
      availability_zone = "eu-west-2b"
    }
  }
}



variable "ssh_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "82.9.238.42/32"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

}
