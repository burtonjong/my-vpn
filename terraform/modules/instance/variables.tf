variable "subnet_id" {
  description = "The subnet ID for the instance"
  type        = string
}

variable "security_group_id" {
  description = "The SG ID to associate to the instance"
  type        = string
}