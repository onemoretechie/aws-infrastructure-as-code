locals {
  base_tags = merge(
    {
      Module    = "alb"
      ManagedBy = "terraform"
    },
    var.tags,
  )

  https_enabled  = var.certificate_arn != null
  listener_ports = local.https_enabled ? [443] : [80]
}

resource "aws_security_group" "this" {
  name        = "${var.name}-alb"
  description = "Ingress for ${var.name} ALB"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all egress to targets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.base_tags, { Name = "${var.name}-alb" })
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = var.enable_http_listener ? toset(var.ingress_cidr_blocks) : []

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "HTTP from ${each.value}"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = local.https_enabled ? toset(var.ingress_cidr_blocks) : []

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS from ${each.value}"
}

resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  internal           = var.internal
  security_groups    = [aws_security_group.this.id]
  subnets            = var.subnet_ids

  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2
  drop_invalid_header_fields = var.drop_invalid_header_fields

  dynamic "access_logs" {
    for_each = var.access_logs_bucket != null ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(local.base_tags, { Name = var.name })
}

resource "aws_lb_target_group" "default" {
  name        = "${var.name}-default"
  vpc_id      = var.vpc_id
  port        = var.default_target_group.port
  protocol    = var.default_target_group.protocol
  target_type = var.default_target_group.target_type

  deregistration_delay = var.default_target_group.deregistration_delay

  health_check {
    enabled             = true
    path                = var.default_target_group.health_check.path
    port                = var.default_target_group.health_check.port
    protocol            = var.default_target_group.health_check.protocol
    matcher             = var.default_target_group.health_check.matcher
    interval            = var.default_target_group.health_check.interval
    timeout             = var.default_target_group.health_check.timeout
    healthy_threshold   = var.default_target_group.health_check.healthy_threshold
    unhealthy_threshold = var.default_target_group.health_check.unhealthy_threshold
  }

  tags = merge(local.base_tags, { Name = "${var.name}-default" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  count = var.enable_http_listener ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = local.https_enabled ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = local.https_enabled ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.default.arn
    }
  }

  tags = local.base_tags
}

resource "aws_lb_listener" "https" {
  count = local.https_enabled ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  tags = local.base_tags
}

resource "aws_lb_listener_certificate" "extra" {
  for_each = local.https_enabled ? toset(var.additional_certificate_arns) : []

  listener_arn    = aws_lb_listener.https[0].arn
  certificate_arn = each.value
}
