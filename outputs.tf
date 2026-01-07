# Output: Per vedere l'IP del server appena creato
# output "server_public_ip" {
#   value = aws_instance.web_server.public_ip
# }

# Output: DNS dell'ALB per mostrare subito l’URL pubblico del sito
output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
  description = "DNS pubblico dell'Application Load Balancer"
}

# Output: Endpoint del database RDS PostgreSQL
output "rds_endpoint" {
  description = "Endpoint del database PostgreSQL"
  value       = aws_db_instance.postgres.address
}
