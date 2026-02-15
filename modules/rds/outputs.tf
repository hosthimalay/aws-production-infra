output "db_endpoint" {
  value     = aws_db_instance.postgres.endpoint
  sensitive = true
}
output "db_name" { value = aws_db_instance.postgres.db_name }
output "rds_sg_id" { value = aws_security_group.rds.id }
