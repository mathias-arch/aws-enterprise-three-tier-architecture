variable "region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "mathias-enterprise"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}
