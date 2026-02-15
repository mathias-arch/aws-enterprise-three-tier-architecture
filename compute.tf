# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                = "enterprise-app-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  
  # CORRECCIÓN: Referencia al Target Group (Asegúrate que se llame app_tg donde lo creaste)
  target_group_arns = [aws_lb_target_group.app_tg.arn] 
  
  # Sincronizado con vpc.tf
  vpc_zone_identifier = [aws_subnet.priv_app_1.id, aws_subnet.priv_app_2.id]

  launch_template {
    # CORRECCIÓN: Referencia al Launch Template (Asegúrate que se llame enterprise_lt)
    id      = aws_launch_template.enterprise_lt.id
    version = "$Latest"
  }
}