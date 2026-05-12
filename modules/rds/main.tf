locals {
  base_tags = merge(
    {
      Module    = "rds"
      ManagedBy = "terraform"
    },
    var.tags,
  )

  engine_defaults = {
    postgres = {
      port             = 5432
      parameter_family = "postgres${split(".", var.engine_version)[0]}"
      default_username = "postgresadmin"
    }
    mysql = {
      port             = 3306
      parameter_family = "mysql${join(".", slice(split(".", var.engine_version), 0, 2))}"
      default_username = "mysqladmin"
    }
  }

  effective_port             = var.port != null ? var.port : local.engine_defaults[var.engine].port
  effective_username         = var.master_username != null ? var.master_username : local.engine_defaults[var.engine].default_username
  effective_parameter_family = local.engine_defaults[var.engine].parameter_family

  monitoring_role_needed = var.monitoring_interval > 0
}

resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids

  tags = merge(local.base_tags, { Name = var.name })
}

resource "aws_security_group" "this" {
  name        = "${var.name}-rds"
  description = "Ingress for ${var.name} RDS instance"
  vpc_id      = var.vpc_id

  tags = merge(local.base_tags, { Name = "${var.name}-rds" })
}

resource "aws_vpc_security_group_ingress_rule" "from_sg" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = local.effective_port
  to_port                      = local.effective_port
  description                  = "DB ingress from ${each.value}"
}

resource "aws_vpc_security_group_ingress_rule" "from_cidr" {
  for_each = toset(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = local.effective_port
  to_port           = local.effective_port
  description       = "DB ingress from ${each.value}"
}

resource "aws_db_parameter_group" "this" {
  name        = "${var.name}-${replace(local.effective_parameter_family, ".", "-")}"
  family      = local.effective_parameter_family
  description = "Parameters for ${var.name}"

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = local.base_tags
}

data "aws_iam_policy_document" "monitoring_assume" {
  count = local.monitoring_role_needed ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "monitoring" {
  count              = local.monitoring_role_needed ? 1 : 0
  name               = "${var.name}-rds-monitoring"
  assume_role_policy = data.aws_iam_policy_document.monitoring_assume[0].json

  tags = local.base_tags
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  count = local.monitoring_role_needed ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "this" {
  identifier = var.name

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_name  = var.database_name
  username = local.effective_username

  manage_master_user_password = var.manage_master_password
  password                    = var.manage_master_password ? null : var.master_password

  port = local.effective_port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = aws_db_parameter_group.this.name
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  copy_tags_to_snapshot   = true

  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval
  monitoring_role_arn          = local.monitoring_role_needed ? aws_iam_role.monitoring[0].arn : null

  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  final_snapshot_identifier  = var.skip_final_snapshot ? null : "${var.name}-final-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  apply_immediately          = false
  auto_minor_version_upgrade = true

  tags = merge(local.base_tags, { Name = var.name })

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }
}
