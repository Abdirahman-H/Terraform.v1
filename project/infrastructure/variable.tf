variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet1_cidr" {
  description = "The CIDR block for the first private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet1_cidr" {
  description = "The CIDR block for the first public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet2_cidr" {
  description = "The CIDR block for the second private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "public_subnet2_cidr" {
  description = "The CIDR block for the second public subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "first_az" {
  description = "The first availability zone"
  type        = string
  default     = "eu-west-2a"
}

variable "second_az" {
  description = "The second availability zone"
  type        = string
  default     = "eu-west-2b"
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

