output "alb_dns_name" {
  description = "Dirección pública del balanceador para acceder a la web"
  value       = aws_lb.web_alb.dns_name
}

output "db_endpoint" {
  description = "Punto de enlace de la base de datos"
  value       = aws_db_instance.mysql_db.endpoint
}