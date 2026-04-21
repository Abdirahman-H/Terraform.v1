variable "subnet_ids" {
  description = "The subnet IDs for the database instances"
  type        = list(string)
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

variable "security_group_ids" {
  description = "The security group IDs for the database instances"
  type        = list(string)
}
