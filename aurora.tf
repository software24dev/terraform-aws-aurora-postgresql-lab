# aurora.tf - Aurora PostgreSQL cluster and instances

# Cluster parameter group - settings that apply to the entire cluster
# Like postgresql.conf settings that affect replication behavior
resource "aws_rds_cluster_parameter_group" "aurora" {
  family = "aurora-postgresql17"
  name   = "${var.project_name}-${var.environment}-cluster-params"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cluster-params"
  }
}

# Instance parameter group - settings for individual instances
# Like instance-specific postgresql.conf overrides
resource "aws_db_parameter_group" "aurora" {
  family = "aurora-postgresql17"
  name   = "${var.project_name}-${var.environment}-instance-params"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-instance-params"
  }
}

# The Aurora cluster itself - shared storage and cluster-level config
resource "aws_rds_cluster" "aurora" {
  cluster_identifier = var.cluster_id
  engine             = "aurora-postgresql"
  engine_version     = var.engine_version

  database_name   = var.db_name
  master_username = var.db_username
  master_password = var.db_password

  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  vpc_security_group_ids          = [aws_security_group.aurora.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name

  # Backup configuration
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"

  # Maintenance
  preferred_maintenance_window = "sun:04:00-sun:05:00"

  # Storage encryption (always enable, even in labs)
  storage_encrypted = true

  # Lab settings - DO NOT use these in production
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name        = var.cluster_id
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Writer instance - the primary node
resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.cluster_id}-writer"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  db_parameter_group_name = aws_db_parameter_group.aurora.name
  publicly_accessible     = true

  tags = {
    Name = "${var.cluster_id}-writer"
    Role = "writer"
  }
}

# Reader instance - the read replica
resource "aws_rds_cluster_instance" "reader" {
  identifier         = "${var.cluster_id}-reader-1"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  db_parameter_group_name = aws_db_parameter_group.aurora.name
  publicly_accessible     = true

  tags = {
    Name = "${var.cluster_id}-reader-1"
    Role = "reader"
  }
}
