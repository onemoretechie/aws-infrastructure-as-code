locals {
  base_tags = merge(
    {
      Module    = "iam"
      ManagedBy = "terraform"
    },
    var.tags,
  )
}

data "aws_iam_policy_document" "service_trust" {
  count = var.trust_type == "service" ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.trust_service_principals
    }
  }
}

data "aws_iam_policy_document" "aws_trust" {
  count = var.trust_type == "aws" ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.trust_aws_principals
    }
  }
}

data "aws_iam_policy_document" "oidc_trust" {
  count = var.trust_type == "oidc" ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.trust_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.trust_oidc_provider_arn, "/^.*oidc-provider\\//", "")}:aud"
      values   = [var.trust_oidc_audience]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.trust_oidc_provider_arn, "/^.*oidc-provider\\//", "")}:sub"
      values   = var.trust_oidc_subjects
    }
  }
}

resource "aws_iam_role" "this" {
  name        = var.name
  path        = var.path
  description = var.description

  assume_role_policy = (
    var.trust_type == "service" ? data.aws_iam_policy_document.service_trust[0].json :
    var.trust_type == "aws" ? data.aws_iam_policy_document.aws_trust[0].json :
    var.trust_type == "oidc" ? data.aws_iam_policy_document.oidc_trust[0].json :
    var.trust_custom_policy_json
  )

  max_session_duration = var.max_session_duration
  permissions_boundary = var.permissions_boundary_arn

  tags = merge(local.base_tags, { Name = var.name })
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = var.name
  role = aws_iam_role.this.name
  path = var.path

  tags = merge(local.base_tags, { Name = var.name })
}
