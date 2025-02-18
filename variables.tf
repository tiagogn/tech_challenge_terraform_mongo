variable "region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o MongoDB será provisionado"
  type        = string
}

variable "eks_security_group_id" {
  description = "ID do Security Group do EKS que pode acessar o MongoDB"
  type        = string
}

variable "subnets" {
  description = "Lista de subnets privadas para o MongoDB"
  type        = list(string)
}

variable "db_username" {
  description = "Nome de usuário para autenticação no MongoDB"
  type        = string
}

variable "db_password" {
  description = "Senha do usuário do MongoDB"
  type        = string
  sensitive   = true  # Protege a exibição da senha no Terraform
}