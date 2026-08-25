variable "cluster_name" {
  type        = string
  description = "Nome do cluster EKS"

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0 && length(var.cluster_name) <= 100
    error_message = "cluster_name deve conter entre 1 e 100 caracteres."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "Lista de subnets privadas para o cluster e worker nodes"

  validation {
    condition     = length(var.subnet_ids) >= 2 && length(distinct(var.subnet_ids)) == length(var.subnet_ids)
    error_message = "subnet_ids deve conter pelo menos duas subnets distintas."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Versão minor do Kubernetes. Quando null, utiliza a versão padrão oferecida pelo EKS."
  default     = null
  nullable    = true

  validation {
    condition     = var.kubernetes_version == null || can(regex("^1\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version deve usar o formato 1.xx, por exemplo 1.33."
  }
}

variable "endpoint_private_access" {
  type        = bool
  description = "Habilita acesso privado ao endpoint da API Kubernetes."
  default     = true
}

variable "endpoint_public_access" {
  type        = bool
  description = "Habilita acesso público ao endpoint da API Kubernetes."
  default     = false
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "CIDRs autorizados a acessar o endpoint público. Obrigatório quando endpoint_public_access é true."
  default     = []

  validation {
    condition     = alltrue([for cidr in var.public_access_cidrs : can(cidrhost(cidr, 0))])
    error_message = "Todos os valores de public_access_cidrs devem ser blocos CIDR válidos."
  }
}

variable "enabled_cluster_log_types" {
  type        = set(string)
  description = "Tipos de logs do control plane enviados ao CloudWatch Logs."
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  validation {
    condition = alltrue([
      for log_type in var.enabled_cluster_log_types : contains([
        "api",
        "audit",
        "authenticator",
        "controllerManager",
        "scheduler"
      ], log_type)
    ])
    error_message = "enabled_cluster_log_types contém um tipo de log não suportado pelo EKS."
  }
}

variable "desired_nodes" {
  type        = number
  description = "Quantidade desejada de nós no Node Group"
  default     = 2

  validation {
    condition     = var.desired_nodes >= 0 && floor(var.desired_nodes) == var.desired_nodes
    error_message = "desired_nodes deve ser um número inteiro maior ou igual a zero."
  }
}

variable "min_nodes" {
  type        = number
  description = "Quantidade mínima de nós"
  default     = 1

  validation {
    condition     = var.min_nodes >= 0 && floor(var.min_nodes) == var.min_nodes
    error_message = "min_nodes deve ser um número inteiro maior ou igual a zero."
  }
}

variable "max_nodes" {
  type        = number
  description = "Quantidade máxima de nós"
  default     = 3

  validation {
    condition     = var.max_nodes >= 1 && floor(var.max_nodes) == var.max_nodes
    error_message = "max_nodes deve ser um número inteiro maior ou igual a um."
  }
}

variable "instance_types" {
  type        = list(string)
  description = "Tipos de instância para os nós"
  default     = ["t3.medium"]

  validation {
    condition     = length(var.instance_types) > 0 && alltrue([for instance_type in var.instance_types : length(trimspace(instance_type)) > 0])
    error_message = "instance_types deve conter pelo menos um tipo de instância válido."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags adicionais aplicadas aos recursos do módulo."
  default     = {}
}
