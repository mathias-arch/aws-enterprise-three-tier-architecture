# --- OUTPUTS ---

output "alb_dns_name" {
  description = "DNS del Load Balancer para acceder a la web"
  # CORRECCIÓN: Nombre sincronizado con el recurso aws_lb
  value       = aws_lb.enterprise_alb.dns_name 
}

output "db_endpoint" {
  description = "Punto de enlace de la base de datos"
  # Asegúrate de que el recurso en database.tf se llame mysql_db
  value       = aws_db_instance.mysql_db.endpoint
}