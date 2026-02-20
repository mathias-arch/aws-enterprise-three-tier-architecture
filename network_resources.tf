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
