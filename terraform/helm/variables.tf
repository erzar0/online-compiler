variable "redis_ip" {
  description = "IP of the created redis instance"
  type        = string
}

variable "redis_password" {
  description = "Password for the created redis instance"
  type        = string
}

variable "postgres_ip" {
  description = "IP of the created Postgres instance"
  type        = string
}

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

variable "postgres_judge0_database" {
  description = "Judge0 database name in the created Postgres instance"
  type        = string
  default     = "judge0"
}

variable "postgres_flask_database" {
  description = "Flask database name in the created Postgres instance"
  type        = string
  default     = "flask"
}