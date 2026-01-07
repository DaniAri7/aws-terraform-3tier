# 1. Definiamo il Provider (AWS)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 2. Configuriamo la Regione
provider "aws" {
  region = var.aws_region # Francoforte, puoi cambiarla con eu-west-1 (Irlanda)
}