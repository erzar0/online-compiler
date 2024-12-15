variable "redis_ip" {
  description = "IP of the created redis instance"
  type        = string
}

variable "redis_port" {
  description = "Port of the created redis instance"
  type        = number
}

variable "postgres_ip" {
  description = "IP of the created Postgres instance"
  type        = string
}

# variable "postgres_port" {
#   description = "Port of the created Postgres instance"
#   type        = number 
# }

variable "postgres_root_username" {
  description = "Root username for the created Postgres instance"
  type        = string
  default     = "root"
}

variable "postgres_root_password" {
  description = "Root password for the created Postgres instance"
  type        = string
  default     = "judge0"
}

variable "postgres_database" {
  description = "Database name in the created Postgres instance"
  type        = string
  default     = "judge0"
}