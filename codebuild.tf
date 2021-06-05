data "aws_iam_policy_document" "job_assume" {
  count = local.default_job_iam_role

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "job_permissions" {
  count = local.default_job_iam_role

  statement {
    sid       = "AllowAdminAccess"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "job" {
  count = local.default_job_iam_role

  name               = local.job_fullname
  assume_role_policy = data.aws_iam_policy_document.job_assume[count.index].json

  tags = local.common_tags
}

resource "aws_iam_role_policy" "job" {
  count  = local.default_job_iam_role
  name   = local.job_fullname
  role   = aws_iam_role.job[count.index].id
  policy = data.aws_iam_policy_document.job_permissions[count.index].json
}

resource "aws_security_group" "default_sg" {
  count       = local.default_vpc_sg ? 1 : 0
  name        = local.job_fullname
  description = "Default security group for CodeBuild job ${local.job_fullname}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_codebuild_source_credential" "job" {
  count = var.source_type == "GITHUB" || var.source_type == "GITHUB_ENTERPRISE" || var.source_type == "BITBUCKET" ? local.enabled : 0

  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = var.source_type
  token       = var.source_creds_token
}

resource "aws_codebuild_project" "job" {
  count = local.enabled

  name          = local.job_fullname
  description   = "The CodeBuild job for ${var.repository_name}"
  service_role  = local.default_job_iam_role > 0 ? aws_iam_role.job[count.index].arn : var.job_iam_role
  build_timeout = var.job_build_timeout
  badge_enabled = true

  dynamic "artifacts" {
    for_each = var.enable_artifacts ? [1] : []
    content {
      type = var.artifacts_type

    }

  }

  dynamic "cache" {
    for_each = var.enable_docker_cache ? [1] : []
    content {
      type  = "LOCAL"
      modes = ["LOCAL_DOCKER_LAYER_CACHE"]
    }
  }

  dynamic "cache" {
    for_each = var.enable_s3_cache ? [1] : []
    content {
      type     = "S3"
      location = var.s3_cache_location
    }
  }

  environment {
    compute_type    = var.job_build_compute_type
    image           = var.job_build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.job_build_privileged_override
  }

  source {
    type      = var.source_type
    location  = var.repository_url
    buildspec = var.buildspec_file

    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = local.job_fullname
      stream_name = "logs"
      status      = "ENABLED"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.example.id}/build-log"
    }
  }

  dynamic "vpc_config" {
    for_each = local.deploy_in_vpc ? [var.vpc_id] : []
    content {
      vpc_id             = var.vpc_id
      subnets            = var.vpc_subnets
      security_group_ids = local.default_vpc_sg ? [aws_security_group.default_sg[count.index].id] : var.vpc_security_groups
    }
  }

  tags = local.common_tags
}
