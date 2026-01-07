# 3. Creiamo la nostra prima risorsa: Una VPC (Virtual Private Cloud)
# Questa è la "bolla" isolata dove vivrà l'infrastruttura
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "VPC-Progetto-Sicurezza"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# 4. Subnet Pubblica (Per risorse che devono parlare con Internet)
resource "aws_subnet" "public_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true #Ogni ISTANZA creata nella subnet riceverà automaticamente un IP pubblico

  tags = {
    Name = "Subnet-Pubblica-${count.index + 1}"
  }
}

# 5. Subnet Privata (Per Database o dati sensibili - Isolata)
resource "aws_subnet" "private_subnet" {
  count             = length(var.availability_zones) 
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Subnet-Privata-${count.index + 1}"
  }
}

# 6. Internet Gateway (La "Porta" verso Internet per la VPC)
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "IGW-Progetto"
  }
}

# 7. Route Table per la Subnet Pubblica
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  # Regola: Tutto il traffico verso 0.0.0.0/0 (Internet) va all'IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "Tabella-Rotte-Pubblica"
  }
}

# 8. Associazione della Route Table alla Subnet Pubblica
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}
