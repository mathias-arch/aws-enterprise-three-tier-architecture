# 1. GRUPO DE SUBREDES PARA LA DB (Para que sepa dónde vivir)
resource "aws_db_subnet_group" "db_sub_group" {
  name       = "${var.project_name}-db-subnets"
  # Ponemos la DB en las subredes más profundas y seguras
  subnet_ids = [aws_subnet.priv_app_1.id, aws_subnet.priv_app_2.id]

  tags = { Name = "DB-Subnet-Group" }
}

# 2. LA INSTANCIA DE BASE DE DATOS (RDS)
resource "aws_db_instance" "mysql_db" {
  allocated_storage      = 10
  db_name                = "enterprise_db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro" # Capa gratuita
  username               = "admin"
  password               = "MathiasCloud2026" # En producción usaríamos un Secret Manager
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  
  # Conectamos con el Security Group que creamos en security.tf
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_sub_group.name
}