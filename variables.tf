# Variabile per l'IP pubblico (per SSH sicuro)
variable "my_ip" {
  description = "Il tuo indirizzo IP pubblico per accesso SSH"
  type        = string
}

# Variabile per la regione AWS
variable "aws_region" {
  description = "Regione AWS dove distribuire l'infrastruttura"
  type        = string
  default     = "eu-central-1"
}

# Variabile per il tipo di istanza EC2
variable "instance_type" {
  description = "Tipo di istanza EC2 (Free Tier)"
  type        = string
  default     = "t2.micro"
}

# Variabile per la zona di disponibilità
variable "availability_zones" {
  description = "Lista delle zone di disponibilità"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

# Lista di indirizzi per le Subnet Pubbliche
variable "public_subnets_cidr" {
  description = "CIDR per le subnet pubbliche"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Lista di indirizzi per le Subnet Private
variable "private_subnets_cidr" {
  description = "CIDR per le subnet private"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "db_password" {
  description = "Password per l'utente admin del database RDS"
  type        = string
  sensitive   = true
}