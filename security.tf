# --- SECURITY GROUPS ---

# 1. Security Group para el Balanceador (ALB)
resource "aws_security_group" "alb_sg" {
  name        = "enterprise-alb-sg"
  description = "Permite trafico HTTP desde internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Security Group para la Aplicación (EC2/ASG)
resource "aws_security_group" "app_sg" {
  name        = "enterprise-app-sg"
  description = "Permite trafico solo desde el ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Conexión con alb_sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Security Group para la Base de Datos (RDS)
resource "aws_security_group" "db_sg" {
  name        = "enterprise-db-sg"
  description = "Permite trafico solo desde la App"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id] # Conexión con app_sg
  }
}