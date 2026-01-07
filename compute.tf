# 10. Recupero dell'ultima AMI di Amazon Linux 2023 (Metodo dinamico)
data "aws_ami" "latest_amazon_linux" {
  most_recent = true   #Prendi l'AMI più recente
  owners      = ["amazon"]   # Proprietario ufficiale Amazon

  filter {
    name   = "name"   
    values = ["al2023-ami-minimal-*-x86_64"]  # Usa la versione minimal per evitare ECS
  }
}

# # 11. Creazione dell'Istanza EC2
# resource "aws_instance" "web_server" {
#   ami           = data.aws_ami.latest_amazon_linux.id
#   instance_type = var.instance_type # <--- Free Tier

#   # Inseriamo l'istanza nella Subnet Pubblica
#   subnet_id                   = aws_subnet.public_subnet[0].id
  
#   # Colleghiamo il Security Group creato prima
#   vpc_security_group_ids      = [aws_security_group.web_sg.id]
  
#   # Assegniamo un IP Pubblico automaticamente
#   associate_public_ip_address = true

#   # Il nome della chiave creata sulla console
#   key_name = "progetto-chiave"

#   # SCRIPT DI AVVIO AUTOMATICO
#   user_data = <<-EOF
#               #!/bin/bash
#               dnf update -y
#               dnf install -y httpd
#               systemctl start httpd
#               systemctl enable httpd
#               echo "<h1>Hello world</h1>" > /var/www/html/index.html
#               EOF

#   tags = {
#     Name = "WebServer-Studio"
#   }
# }

