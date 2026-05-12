locals {
  base_tags = merge(
    {
      Module    = "ecr"
      ManagedBy = "terraform"
    },
    var.tags,
  )

  tagged_rules = [
    for idx, prefix in var.lifecycle_tag_prefixes : {
      rulePriority = idx + 1
      description  = "Keep last ${var.lifecycle_keep_last_n_tagged} images tagged '${prefix}*'"
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = [prefix]
        countType     = "imageCountMoreThan"
        countNumber   = var.lifecycle_keep_last_n_tagged
      }
      action = { type = "expire" }
    }
    if var.lifecycle_keep_last_n_tagged > 0
  ]

  untagged_rule = var.lifecycle_untagged_expire_days > 0 ? [{
    rulePriority = length(local.tagged_rules) + 1
    description  = "Expire untagged images after ${var.lifecycle_untagged_expire_days} days"
    selection = {
      tagStatus   = "untagged"
      countType   = "sinceImagePushed"
      countUnit   = "days"
      countNumber = var.lifecycle_untagged_expire_days
    }
    action = { type = "expire" }
  }] : []

  lifecycle_rules = concat(local.tagged_rules, local.untagged_rule)
}

resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.kms_key_arn != null ? "KMS" : "AES256"
    kms_key         = var.kms_key_arn
  }

  tags = merge(local.base_tags, { Name = var.name })
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = length(local.lifecycle_rules) > 0 ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = jsonencode({ rules = local.lifecycle_rules })
}

data "aws_iam_policy_document" "pull" {
  count = length(var.allowed_pull_principal_arns) > 0 ? 1 : 0

  statement {
    sid    = "AllowPull"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.allowed_pull_principal_arns
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
  }
}

resource "aws_ecr_repository_policy" "this" {
  count = length(var.allowed_pull_principal_arns) > 0 ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = data.aws_iam_policy_document.pull[0].json
}
