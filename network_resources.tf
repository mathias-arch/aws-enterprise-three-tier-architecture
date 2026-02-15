# 1. Application Load Balancer (ALB)
resource "aws_lb" "enterprise_alb" {
  name               = "enterprise-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.pub_1.id, aws_subnet.pub_2.id]

  tags = { Name = "Enterprise-ALB" }
}

# 2. Target Group (Para el Auto Scaling)
resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# 3. Listener del ALB (Redirige el tráfico al Target Group)
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.enterprise_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 4. Launch Template (Define cómo son las instancias EC2)
resource "aws_launch_template" "enterprise_lt" {
  name_prefix   = "enterprise-lt-"
  image_id      = "ami-0c101f26f147fa7fd" # Amazon Linux 2023 en us-east-1
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hola desde tu arquitectura Cloud en AWS</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "Enterprise-Web-App" }
  }
}