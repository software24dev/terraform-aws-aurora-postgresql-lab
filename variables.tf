# variables.tf - All configurable parameters for this Aurora deployment

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources (like a schema name)"
  type        = string
  default     = "dba-lab"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "auroradb"
}

variable "db_username" {
  description = "Master username for the Aurora cluster"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password for the Aurora cluster"
  type        = string
  sensitive   = true
}

variable "cluster_id" {
  description = "Unique identifier for the Aurora cluster"
  type        = string
  default     = "dba-lab-aurora"
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  description = "Aurora instance size (db.t3.medium is the minimum for Aurora)"
  type        = string
  default     = "db.t3.medium"
}

variable "my_ip" {
  description = "Your public IP address for security group access (without /32)"
  type        = string
}
