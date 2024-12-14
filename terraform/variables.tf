variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The region where resources will be deployed"
  type        = string
  default     = "europe-central2"
}

variable "zone" {
  description = "The zone within the region for resources"
  type        = string
  default     = "europe-central2-c"
}

variable "vpc_network_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "main"
}

variable "subnet_private_ip_range" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "10.0.0.0/18"
}

variable "subnet_pod_range" {
  description = "The CIDR block for Kubernetes pods"
  type        = string
  default     = "10.48.0.0/14"
}

variable "subnet_service_range" {
  description = "The CIDR block for Kubernetes services"
  type        = string
  default     = "10.52.0.0/20"
}

variable "nat_ip_name" {
  description = "The name of the NAT IP address resource"
  type        = string
  default     = "nat"
}

variable "db_instance_tier" {
  description = "The machine type for the database instance"
  type        = string
  default     = "db-f1-micro"
}

variable "kubernetes_machine_type" {
  description = "The machine type for Kubernetes nodes"
  type        = string
  default     = "e2-small"
}

variable "spot_min_nodes" {
  description = "The minimum number of spot nodes"
  type        = number
  default     = 0
}

variable "spot_max_nodes" {
  description = "The maximum number of spot nodes"
  type        = number
  default     = 5
}