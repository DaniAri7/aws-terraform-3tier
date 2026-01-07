# Target Group per il web server
resource "aws_lb_target_group" "web_tg" {
  name     = "tg-web-server"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399" # Consideriamo sano se risponde con codice 2xx o 3xx
    healthy_threshold   = 2 # Numero di risposte sane consecutive per considerare il target sano
    unhealthy_threshold = 2 
    timeout             = 5 # Timeout per la risposta del target altrimenti healt check fallito
    interval            = 30 # Ogni quanto eseguire l'health check
  }

  tags = {
    Name = "TG-Web-Server"
  }
}

# Application Load Balancer pubblico
resource "aws_lb" "app_alb" {
  name               = "alb-web-server"
  load_balancer_type = "application"
  internal           = false # Pubblico

  security_groups = [aws_security_group.alb_sg.id]

  # Usiamo tutte le subnet pubbliche (multi-AZ)
  subnets = aws_subnet.public_subnet[*].id

  tags = {
    Name = "ALB-Web-Server"
  }
}

# Listener HTTP dell'ALB - ALB in ascolto su porta 80 e inoltra al Target Group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Associazione dell'istanza EC2 al Target Group
# resource "aws_lb_target_group_attachment" "web_tg_attachment" {
#   target_group_arn = aws_lb_target_group.web_tg.arn # Collegamento al Target Group
#   target_id        = aws_instance.web_server.id # ID dell'istanza EC2
#   port             = 80
# }