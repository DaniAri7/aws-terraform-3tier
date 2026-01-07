# NAT Gateway e route per le subnet private

# Elastic IP per il NAT Gateway (serve un IP pubblico associato al NAT)
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT-EIP"
  }
}

# NAT Gateway nelle subnet pubbliche (usiamo la prima subnet pubblica)
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id # Mettiamo il NAT Gateway nella prima subnet pubblica

  tags = {
    Name = "NAT-Gateway-Principal"
  }

  depends_on = [aws_internet_gateway.main_igw] # Assicuriamoci che l'IGW sia creato prima del NAT Gateway e della route table
}

# Route table per le subnet private
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  # Tutto il traffico verso Internet passa dal NAT Gateway
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Tabella-Rotte-Private"
  }

  depends_on = [aws_internet_gateway.main_igw]
}

# Associazione della route table privata alle subnet private
resource "aws_route_table_association" "private_assoc" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
