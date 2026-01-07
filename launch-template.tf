resource "aws_launch_template" "web_lt" {
  name_prefix   = "lt-web-server-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type

  # Security Group del web server (solo traffico dall'ALB)
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  key_name = "progetto-chiave"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello world</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "WebServer-ASG"
    }
  }
}
