# ---------------------------------------------------------
# 1. SECURITY GROUP PARA EL LOAD BALANCER (ALB)
# ---------------------------------------------------------
# El ALB es el único que da la cara a Internet.
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Permitir trafico HTTP desde el mundo"
  vpc_id      = aws_vpc.main.id

  # Entrada: HTTP desde cualquier parte
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida: Todo permitido
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ALB-Security-Group" }
}

# ---------------------------------------------------------
# 2. SECURITY GROUP PARA LOS SERVIDORES WEB (APP)
# ---------------------------------------------------------
# ¡SEGURIDAD CLAVE!: Solo aceptamos tráfico que venga del ALB.
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Permitir trafico solo desde el ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Solo el ALB tiene la llave
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Web-Server-SG" }
}

# ---------------------------------------------------------
# 3. SECURITY GROUP PARA LA BASE DE DATOS (RDS)
# ---------------------------------------------------------
# ¡MÁXIMA SEGURIDAD!: Solo los servidores web pueden hablar con la DB.
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Permitir trafico MySQL desde la capa Web"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # Solo la web entra aquí
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Database-SG" }
}