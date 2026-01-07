resource "aws_autoscaling_group" "web_asg" {
  name                      = "asg-web-server"
  desired_capacity          = 2 
  min_size                  = 1 
  max_size                  = 3 

  # Subnet PRIVATE dove verranno create le istanze
  vpc_zone_identifier = aws_subnet.private_subnet[*].id

  # Collegamento con il Launch Template
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest" # Serve per usare l'ultima versione dell'LT, altrimenti utilizzerebbe sempre la prima versione dell'LT che abbiamo creato
  }

  # Collega l'ASG al Target Group dell'ALB
  target_group_arns = [aws_lb_target_group.web_tg.arn]

  # Health check di ASG, health check di ALB decide se inviare traffico. L’ASG decide se rimpiazzare l’istanza
  health_check_type         = "EC2"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "WebServer-ASG-Instance"
    propagate_at_launch = true 
  }

  lifecycle {
    create_before_destroy = true # Per evitare downtime durante aggiornamenti
  }
}
