variable "environment" {
  type        = string
  description = "Nome do ambiente (ex: local, prod)"
}

variable "cidr_block" {
  type        = string
  description = "Bloco CIDR principal da VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "Zonas de disponibilidade"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  type        = list(string)
  description = "Lista de CIDRs para as subnets públicas"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "Lista de CIDRs para as subnets privadas"
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}
