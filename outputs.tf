# outputs.tf - Connection information for the Aurora cluster

output "cluster_endpoint" {
  description = "Aurora cluster endpoint (connects to writer)"
  value       = aws_rds_cluster.aurora.endpoint
}

output "reader_endpoint" {
  description = "Aurora reader endpoint (load-balanced across readers)"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "cluster_port" {
  description = "Aurora cluster port"
  value       = aws_rds_cluster.aurora.port
}

output "database_name" {
  description = "Name of the initial database"
  value       = aws_rds_cluster.aurora.database_name
}

output "writer_connection" {
  description = "psql command to connect to the writer"
  value       = "psql -h ${aws_rds_cluster.aurora.endpoint} -p ${aws_rds_cluster.aurora.port} -U ${var.db_username} -d ${var.db_name}"
}

output "reader_connection" {
  description = "psql command to connect to a reader (load balanced)"
  value       = "psql -h ${aws_rds_cluster.aurora.reader_endpoint} -p ${aws_rds_cluster.aurora.port} -U ${var.db_username} -d ${var.db_name}"
}

output "vpc_id" {
  description = "VPC ID where Aurora lives"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "Security group ID controlling Aurora access"
  value       = aws_security_group.aurora.id
}
