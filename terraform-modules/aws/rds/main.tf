data "aws_rds_engine_version" "default" {
  engine = var.engine
}

locals {
  engine_version = var.engine_version != "" ? var.engine_version : data.aws_rds_engine_version.default.version
  port = var.port != null ? var.port : (
    var.engine == "mysql" ? 3306 :
    var.engine == "postgres" ? 5432 :
    var.engine == "oracle-ee" ? 1521 :
    var.engine == "oracle-se2" ? 1521 :
    var.engine == "sqlserver-ex" ? 1433 :
    var.engine == "sqlserver-web" ? 1433 :
    var.engine == "sqlserver-se" ? 1433 :
    var.engine == "sqlserver-ee" ? 1433 :
    3306
  )
  parameter_group_family = var.parameter_group_family != "" ? var.parameter_group_family : "${var.engine}${split(".", local.engine_version)[0]}.${split(".", local.engine_version)[1]}"
}

resource "aws_db_subnet_group" "main" {
  count = var.db_subnet_group_name == "" && length(var.subnet_ids) > 0 ? 1 : 0

  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-subnet-group"
    }
  )
}

resource "aws_db_parameter_group" "main" {
  count = var.parameter_group_name == "" && length(var.parameters) > 0 ? 1 : 0

  family = local.parameter_group_family
  name   = "${var.name}-parameter-group"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-parameter-group"
    }
  )
}

resource "aws_db_instance" "main" {
  identifier     = var.name
  engine         = var.engine
  engine_version = local.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id           = var.kms_key_id != "" ? var.kms_key_id : null

  db_name  = var.database_name != "" ? var.database_name : null
  username = var.username
  password = var.manage_master_user_password ? null : (var.password != "" ? var.password : null)
  port     = local.port

  manage_master_user_password = var.manage_master_user_password

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name != "" ? var.db_subnet_group_name : (length(var.subnet_ids) > 0 ? aws_db_subnet_group.main[0].name : null)

  parameter_group_name = var.parameter_group_name != "" ? var.parameter_group_name : (length(var.parameters) > 0 ? aws_db_parameter_group.main[0].name : null)
  option_group_name    = var.option_group_name != "" ? var.option_group_name : null

  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window

  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn != "" ? var.monitoring_role_arn : null

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : (var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : "${var.name}-final-snapshot")

  copy_tags_to_snapshot = var.copy_tags_to_snapshot

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}