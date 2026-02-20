# 1. Auto Scaling Group
# Este recurso crea el grupo de instancias que se escalan automáticamente
resource "aws_autoscaling_group" "app_asg" {
  name             = "enterprise-app-asg"
  desired_capacity = 2
  max_size         = 4
  min_size         = 2

  # Referencia al Target Group para el Load Balancer
  target_group_arns = [aws_lb_target_group.app_tg.arn]

  # Subredes privadas donde vivirán las instancias (Sincronizado con vpc.tf)
  vpc_zone_identifier = [aws_subnet.priv_app_1.id, aws_subnet.priv_app_2.id]

  launch_template {
    id      = aws_launch_template.enterprise_lt.id
    version = "$Latest"
  }
}

# 2. Launch Template
# Define la configuración de cada instancia EC2 que lanza el ASG
resource "aws_launch_template" "enterprise_lt" {
  name_prefix   = "enterprise-lt-"
  image_id      = "ami-0c101f26f147fa7fd" # Amazon Linux 2023 en us-east-1
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hola desde el servidor Enterprise" > index.html
              nohup python3 -m http.server 80 &
              EOF
  )

  # --- EL BLOQUE DE SEGURIDAD ---
  # Esto evita que el ASG se quede sin plantilla durante actualizaciones
  lifecycle {
    create_before_destroy = true
  }
}