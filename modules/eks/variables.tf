variable "cluster_name" {
  type        = string
  description = "Nome do cluster EKS"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Lista de subnets privadas para o cluster e worker nodes"
}

variable "desired_nodes" {
  type        = number
  description = "Quantidade desejada de nós no Node Group"
  default     = 2
}

variable "min_nodes" {
  type        = number
  description = "Quantidade mínima de nós"
  default     = 1
}

variable "max_nodes" {
  type        = number
  description = "Quantidade máxima de nós"
  default     = 3
}

variable "instance_types" {
  type        = list(string)
  description = "Tipos de instância para os nós"
  default     = ["t3.medium"]
}
