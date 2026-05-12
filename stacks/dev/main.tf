locals {
  environment = "dev"
  common_tags = {
    Environment = local.environment
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name               = local.environment
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  nat_gateway_mode   = "single"
  enable_flow_logs   = false

  tags = local.common_tags
}

# --- KMS keys ----------------------------------------------------------------

module "kms_s3" {
  source = "../../modules/kms"

  name               = "${local.environment}-s3"
  description        = "Encrypts dev S3 buckets"
  service_principals = ["s3.amazonaws.com"]

  tags = local.common_tags
}

# --- S3 ----------------------------------------------------------------------

module "uploads_bucket" {
  source = "../../modules/s3"

  name        = "${var.bucket_name_prefix}-${local.environment}-uploads"
  kms_key_arn = module.kms_s3.key_arn

  lifecycle_rules = [{
    id = "expire-noncurrent"
    transitions = [
      { days = 30, storage_class = "STANDARD_IA" },
    ]
    noncurrent_version_expiration_days     = 90
    abort_incomplete_multipart_upload_days = 7
  }]

  tags = local.common_tags
}

# --- ECR ---------------------------------------------------------------------

module "ecr_app" {
  source = "../../modules/ecr"

  name                           = "sample-web-app"
  lifecycle_keep_last_n_tagged   = 20
  lifecycle_untagged_expire_days = 7

  tags = local.common_tags
}

# --- IAM role example: bastion / SSM-managed EC2 -----------------------------

module "ec2_role" {
  source = "../../modules/iam"

  name                     = "${local.environment}-ssm-managed-ec2"
  description              = "Lets EC2 instances be SSM-managed (Session Manager, Patch Manager)."
  trust_type               = "service"
  trust_service_principals = ["ec2.amazonaws.com"]
  managed_policy_arns      = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  create_instance_profile  = true

  tags = local.common_tags
}

# --- RDS (optional) ----------------------------------------------------------

module "kms_rds" {
  count  = var.enable_rds ? 1 : 0
  source = "../../modules/kms"

  name               = "${local.environment}-rds"
  description        = "Encrypts dev RDS storage + snapshots"
  service_principals = ["rds.amazonaws.com"]

  tags = local.common_tags
}

module "rds" {
  count  = var.enable_rds ? 1 : 0
  source = "../../modules/rds"

  name           = "${local.environment}-app"
  engine         = "postgres"
  engine_version = var.rds_engine_version
  instance_class = "db.t4g.micro"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.database_subnet_ids

  kms_key_arn   = module.kms_rds[0].key_arn
  database_name = "app"

  multi_az            = false
  deletion_protection = false
  skip_final_snapshot = true

  performance_insights_enabled = false
  monitoring_interval          = 0

  tags = local.common_tags
}
