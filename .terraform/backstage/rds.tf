locals {
  db_identifier = "backstage-db"
  db_user       = "postgres"
  db_password = "sometest"
  db_port     = "5432"
  db_name     = "postgres"
}

resource "aws_ssm_parameter" "rds_db_secret" {
  name  = "/fargate/backstage/${local.project_prefix}/rds_db_secret"
  type  = "SecureString"
  value = var.rds_db_secret
  tags  = var.default_tags
}

resource "aws_security_group" "rds" {
  name        = "${local.project_prefix}-rds-instance-sg"
  description = "${local.project_prefix}-rds-instance-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow 5432 from Fargate"
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    # Not sure how to get this value from the ECS module
    # and allow TF to determine order to create resources
    # Since ECS module depends on RDS module and vice versa
    # security_groups = [
    #   module.ecs.services[local.container_name].security_group_id
    # ]
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.db_identifier

  engine            = "postgres"
  engine_version    = "15.3"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = local.db_name
  username = local.db_user
  port     = local.db_port

  iam_database_authentication_enabled = false

  # Allow RDS to manage the master user password
  manage_master_user_password = false # set to true in non-demo project

  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  # monitoring_interval    = "30"
  # monitoring_role_name   = "MyRDSMonitoringRole"
  # create_monitoring_role = true

  # Password will not be used if manage_master_user_password=true
  password = local.db_password

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  # DB parameter group
  family = "postgres15"

  major_engine_version = "15"
  deletion_protection  = false
}
