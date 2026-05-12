locals {
  environment = "prod"
  common_tags = {
    Environment = local.environment
  }

  app_fqdn = "${var.app_subdomain}.${var.domain_name}"
  cdn_fqdn = "${var.cdn_subdomain}.${var.domain_name}"
}

# --- Network -----------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  name               = local.environment
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  nat_gateway_mode   = "per_az"
  enable_flow_logs   = true

  tags = local.common_tags
}

# --- KMS keys ----------------------------------------------------------------

module "kms_s3" {
  source = "../../modules/kms"

  name               = "${local.environment}-s3"
  description        = "Encrypts prod S3 buckets"
  service_principals = ["s3.amazonaws.com"]

  tags = local.common_tags
}

module "kms_rds" {
  source = "../../modules/kms"

  name               = "${local.environment}-rds"
  description        = "Encrypts prod RDS storage + snapshots"
  service_principals = ["rds.amazonaws.com"]

  tags = local.common_tags
}

module "kms_eks" {
  source = "../../modules/kms"

  name               = "${local.environment}-eks-secrets"
  description        = "Envelope-encrypts Kubernetes Secrets in EKS"
  service_principals = ["eks.amazonaws.com"]

  tags = local.common_tags
}

# --- DNS ---------------------------------------------------------------------

module "dns" {
  source = "../../modules/route53"

  zone_name   = var.domain_name
  create_zone = var.create_dns_zone

  tags = local.common_tags
}

# --- ACM certs ---------------------------------------------------------------

module "acm_alb" {
  source = "../../modules/acm"

  domain_name               = local.app_fqdn
  subject_alternative_names = []
  hosted_zone_id            = module.dns.zone_id

  tags = local.common_tags
}

module "acm_cloudfront" {
  source = "../../modules/acm"
  providers = {
    aws = aws.us_east_1
  }

  domain_name    = local.cdn_fqdn
  hosted_zone_id = module.dns.zone_id

  tags = local.common_tags
}

# --- S3 buckets --------------------------------------------------------------

module "logs_bucket" {
  source = "../../modules/s3"

  name        = "${var.bucket_name_prefix}-${local.environment}-logs"
  kms_key_arn = module.kms_s3.key_arn

  lifecycle_rules = [{
    id = "expire-old-logs"
    transitions = [
      { days = 30, storage_class = "STANDARD_IA" },
      { days = 90, storage_class = "GLACIER" },
    ]
    expiration_days                        = 365
    abort_incomplete_multipart_upload_days = 7
  }]

  tags = local.common_tags
}

module "assets_bucket" {
  source = "../../modules/s3"

  name        = "${var.bucket_name_prefix}-${local.environment}-assets"
  kms_key_arn = module.kms_s3.key_arn

  cors_rules = [{
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["https://${local.cdn_fqdn}"]
  }]

  tags = local.common_tags
}

# --- ECR ---------------------------------------------------------------------

module "ecr_app" {
  source = "../../modules/ecr"

  name                           = "sample-web-app"
  image_tag_mutability           = "IMMUTABLE"
  scan_on_push                   = true
  lifecycle_keep_last_n_tagged   = 50
  lifecycle_untagged_expire_days = 14

  tags = local.common_tags
}

# --- RDS ---------------------------------------------------------------------

module "rds" {
  source = "../../modules/rds"

  name           = "${local.environment}-app"
  engine         = "postgres"
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.database_subnet_ids

  kms_key_arn   = module.kms_rds.key_arn
  database_name = "app"

  allowed_security_group_ids = [module.eks.node_security_group_id]

  multi_az                = true
  backup_retention_period = 14
  deletion_protection     = true
  skip_final_snapshot     = false

  tags = local.common_tags
}

# --- EKS ---------------------------------------------------------------------

module "eks" {
  source = "../../modules/eks"

  name               = "${local.environment}-platform"
  kubernetes_version = var.kubernetes_version

  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.private_subnet_ids
  node_subnet_ids          = module.vpc.private_subnet_ids

  kms_key_arn = module.kms_eks.key_arn

  endpoint_public_access  = true
  endpoint_private_access = true

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_capacity_type  = "ON_DEMAND"

  tags = local.common_tags
}

# --- ALB ---------------------------------------------------------------------

module "alb" {
  source = "../../modules/alb"

  name       = "${local.environment}-edge"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  certificate_arn = module.acm_alb.certificate_arn

  default_target_group = {
    port        = 80
    target_type = "ip"
    health_check = {
      path     = "/healthz"
      interval = 15
    }
  }

  enable_deletion_protection = true

  tags = local.common_tags
}

# --- CloudFront --------------------------------------------------------------

module "cloudfront" {
  source = "../../modules/cloudfront"

  name            = "${local.environment}-cdn"
  aliases         = [local.cdn_fqdn]
  certificate_arn = module.acm_cloudfront.certificate_arn

  custom_origin = {
    domain_name            = module.alb.alb_dns_name
    origin_protocol_policy = "https-only"
    origin_ssl_protocols   = ["TLSv1.2"]
  }

  default_cache_behavior = {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  }

  tags = local.common_tags
}

# --- DNS records pointing at the edge ---------------------------------------

module "dns_records" {
  source = "../../modules/route53"

  zone_name   = var.domain_name
  create_zone = false

  records = {
    "app-A" = {
      name = local.app_fqdn
      type = "A"
      alias = {
        name                   = module.alb.alb_dns_name
        zone_id                = module.alb.alb_zone_id
        evaluate_target_health = true
      }
    }
    "cdn-A" = {
      name = local.cdn_fqdn
      type = "A"
      alias = {
        name                   = module.cloudfront.domain_name
        zone_id                = module.cloudfront.hosted_zone_id
        evaluate_target_health = false
      }
    }
  }

  tags = local.common_tags

  depends_on = [module.dns]
}
