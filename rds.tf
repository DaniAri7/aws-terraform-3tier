resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "RDS-Subnet-Group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "progetto-postgres-db"
  engine                  = "postgres" 
  engine_version          = "15.3" 
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100 

  username = "admin"
  password = var.db_password # In produzione si usa Secrets Manager o SSM Parameter Store

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az             = true # Abilita Multi-AZ per alta disponibilità
  publicly_accessible  = false # Non accessibile pubblicamente, accesso disponibile solo dalla VPC
  backup_retention_period = 7 # Conserva i backup automatici per 7 giorni
  skip_final_snapshot     = true # In produzione lo metteremmo false per fare uno snapshot finale

  tags = {
    Name = "PostgreSQL-DB"
  }
}
