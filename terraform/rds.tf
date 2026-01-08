# RDS MySQL Database Instance

#------------------------------------------------------------------------------
# DB Subnet Group
#------------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Database subnet group for ${var.project_name}"
  subnet_ids  = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

#------------------------------------------------------------------------------
# RDS MySQL Instance
#------------------------------------------------------------------------------
resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = "mysql"
  engine_version = "8.0"

  instance_class        = var.db_instance_class
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  multi_az               = false # Set to true for production
  publicly_accessible    = false
  skip_final_snapshot    = true # Set to false for production
  deletion_protection    = false # Set to true for production

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  parameter_group_name = aws_db_parameter_group.main.name

  tags = {
    Name = "${var.project_name}-db"
  }
}

#------------------------------------------------------------------------------
# DB Parameter Group
#------------------------------------------------------------------------------
resource "aws_db_parameter_group" "main" {
  name   = "${var.project_name}-db-params"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  tags = {
    Name = "${var.project_name}-db-params"
  }
}
