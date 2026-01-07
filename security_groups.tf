# 9. Security Group per Web Server
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Consente traffico HTTP dall'ALB e SSH dal proprio IP"
  vpc_id      = aws_vpc.main_vpc.id

  # Ingress: Regole per il traffico in ENTRATA

  # Permettiamo HTTP (Porta 80) solo dall'ALB

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Permettiamo SSH (Porta 22) - SOLO dal proprio IP (Best Practice)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]  # Usa la variabile per flessibilità
  }

  # Egress: Regole per il traffico in USCITA
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Web-Server"
  }
}

# Security Group per l'Application Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Consente traffico HTTP da Internet verso l'ALB"
  vpc_id      = aws_vpc.main_vpc.id

  # Ingress: HTTP da Internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: l'ALB può parlare con qualsiasi destinazione
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-ALB"
  }
}


# Security Group per RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  description = "Consente traffico PostgreSQL solo dal Web Server"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 5432 # Porta standard PostgreSQL
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # Solo connessioni dalle istanze che hanno web_sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "SG-RDS-Postgres"
  }
}
