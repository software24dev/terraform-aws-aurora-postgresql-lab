# security.tf - Network access control
# This is your pg_hba.conf, but at the AWS network level

resource "aws_security_group" "aurora" {
  name        = "${var.project_name}-${var.environment}-aurora-sg"
  description = "Controls network access to Aurora PostgreSQL cluster"
  vpc_id      = aws_vpc.main.id

  # Ingress rule = inbound traffic allowed
  # Like a pg_hba.conf line: host all all <your-ip>/32 scram-sha-256
  ingress {
    description = "PostgreSQL access from my IP"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  # Egress rule = outbound traffic allowed
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-aurora-sg"
  }
}
