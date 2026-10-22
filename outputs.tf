output "rds_endpoint" {
  description = "Endpoint de la base de datos RDS"
  value       = aws_db_instance.crediya_mysql.endpoint
}

output "ecr_autenticacion_url" {
  value = aws_ecr_repository.repo_autenticacion.repository_url
}

output "ecr_solicitudes_url" {
  value = aws_ecr_repository.repo_solicitudes.repository_url
}

output "ecr_reportes_url" {
  value = aws_ecr_repository.repo_reportes.repository_url
}