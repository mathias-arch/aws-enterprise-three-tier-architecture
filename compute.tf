# 1. BUSCAR LA IMAGEN DE AMAZON LINUX (AMI)
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# 2. PLANTILLA DE LANZAMIENTO (Launch Template)
resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro" # Usamos t3.micro que es más moderna para Free Tier

  network_interfaces {
    associate_public_ip_address = false # Están en subred privada
    security_groups             = [aws_security_group.web_sg.id]
  }

  # SCRIPT DE ARRANQUE (Asegúrate de que no haya espacios raros aquí)
  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hola! Servidor en Subred Privada - Mathias Enterprise</h1>" > /var/www/html/index.html
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

# 3. BALANCEADOR DE CARGA (ALB)
resource "aws_lb" "web_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.pub_1.id, aws_subnet.pub_2.id]

  tags = { Name = "Main-ALB" }
}

# 4. GRUPO DE DESTINO (Target Group)
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 5. OYENTE DEL BALANCEADOR (Listener)
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# 6. GRUPO DE AUTO ESCALADO (ASG)
resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.project_name}-asg"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.web_tg.arn]
  vpc_zone_identifier = [aws_subnet.priv_app_1.id, aws_subnet.priv_app_2.id]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
}
