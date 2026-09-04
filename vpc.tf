# vpc.tf - Network infrastructure
# Think of this as building out the datacenter before you rack the database server

# The VPC is your isolated network
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

# Subnets in different Availability Zones
# Aurora requires subnets in at least 2 AZs for failover capability
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-${var.environment}-db-a"
  }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.project_name}-${var.environment}-db-b"
  }
}

resource "aws_subnet" "db_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}c"

  tags = {
    Name = "${var.project_name}-${var.environment}-db-c"
  }
}

# Internet Gateway - allows traffic in/out of the VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# Route table - tells traffic where to go
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rt"
  }
}

# Associate each subnet with the route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.db_c.id
  route_table_id = aws_route_table.main.id
}

# DB Subnet Group - tells Aurora which subnets it can use
resource "aws_db_subnet_group" "aurora" {
  name = "${var.project_name}-${var.environment}-aurora-subnets"
  subnet_ids = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id,
    aws_subnet.db_c.id,
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-aurora-subnets"
  }
}
