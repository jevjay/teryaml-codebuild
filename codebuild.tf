data "aws_iam_policy_document" "service_role_assume" {
  for_each = { for i in local.service_role : i.name => i }

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

resource "aws_iam_role" "service_role" {
  for_each = { for i in local.service_role : i.project_name => i }

  name               = each.value.name
  assume_role_policy = data.aws_iam_policy_document.service_role_assume[each.value.name].json

  tags = local.common_tags
}

resource "aws_iam_role_policy" "service_role_permissions" {
  for_each = { for i in local.service_role : i.name => i if length(i.policy) > 0 }

  name   = "${each.value.name}-permissions"
  role   = aws_iam_role.service_role[each.value.project_name].id
  policy = each.value.policy
}

resource "aws_security_group" "default_sg" {
  for_each = { for i in local.vpc_config : i.project_name => i if length(i.security_group_ids) == 0 }

  name        = "${each.value.project_name}-default"
  description = "Default security group for CodeBuild project: ${each.value.project_name}"
  vpc_id      = each.value.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_codebuild_source_credential" "job" {
  for_each = { for i in local.source_credentials : i.server_type => i if contains(local.git_source_credentials_support, i.source_type) }

  auth_type   = each.value.auth_type
  server_type = each.value.server_type
  token       = each.value.token
  user_name   = each.value.username
}

resource "aws_codebuild_project" "job" {
  for_each = try({ for i in local.project : i.project_name => i }, {})

  name                   = each.value.project_name
  description            = each.value.description
  service_role           = aws_iam_role.service_role[each.value.project_name].arn
  build_timeout          = each.value.build_timeout
  badge_enabled          = each.value.badge_enabled
  concurrent_build_limit = each.value.concurrent_build_limit
  queued_timeout         = each.value.queued_timeout

  dynamic "artifacts" {
    for_each = { for i in local.artifacts : i.project_name => i }

    content {
      type                   = artifacts.value.type
      artifact_identifier    = artifacts.value.artifact_identifier
      bucket_owner_access    = artifacts.value.bucket_owner_access
      encryption_disabled    = artifacts.value.encryption_disabled
      location               = artifacts.value.location
      name                   = artifacts.value.name
      namespace_type         = artifacts.value.namespace_type
      override_artifact_name = artifacts.value.override_artifact_name
      packaging              = artifacts.value.packaging
      path                   = artifacts.value.path
    }
  }

  dynamic "cache" {
    for_each = { for i in local.cache : i.project_name => i }

    content {
      type     = cache.value.type
      location = cache.value.location
      modes    = cache.value.modes
    }
  }

  dynamic "environment" {
    for_each = { for i in local.environment : i.project_name => i }

    content {
      compute_type                = environment.value.compute_type
      image                       = environment.value.image
      type                        = environment.value.type
      certificate                 = environment.value.certificate
      image_pull_credentials_type = environment.value.image_pull_credentials_type
      privileged_mode             = environment.value.privileged_mode

      dynamic "environment_variable" {
        for_each = { for i in local.environment_variables : i.name => i }

        content {
          name  = environment_variable.value.name
          value = environment_variable.value.value
          type  = environment_variable.value.type
        }
      }

      dynamic "registry_credential" {
        for_each = { for i in local.registry_credentials : i.credential_provider => i }

        content {
          credential          = registry_credential.value.credential
          credential_provider = registry_credential.value.credential_provider
        }
      }
    }
  }

  dynamic "source" {
    for_each = { for i in local.source : i.project_name => i }

    content {
      type            = source.value.type
      location        = source.value.location
      buildspec       = source.value.buildspec
      git_clone_depth = source.value.git_clone_depth
      insecure_ssl    = source.value.insecure_ssl

      dynamic "git_submodules_config" {
        for_each = { for i in local.source : i.project_name => i if contains(local.git_submodules_support, i.type) }

        content {
          fetch_submodules = git_submodules_config.value.fetch_git_submodules
        }
      }
    }

  }

  logs_config {
    dynamic "cloudwatch_logs" {
      for_each = { for i in local.clodwatch_logs : i.project_name => i }

      content {
        group_name  = cloudwatch_logs.value.group_name
        stream_name = cloudwatch_logs.value.stream_name
        status      = cloudwatch_logs.value.status
      }
    }

    dynamic "s3_logs" {
      for_each = { for i in local.s3_logs : i.project_name => i }

      content {
        encryption_disabled = s3_logs.value.encryption_disabled
        location            = s3_logs.value.location
        status              = s3_logs.value.status
      }
    }
  }

  dynamic "vpc_config" {
    for_each = { for i in local.vpc_config : i.vpc_id => i }

    content {
      vpc_id             = vpc_config.value.vpc_id
      subnets            = vpc_config.value.subnets
      security_group_ids = length(vpc_config.value.security_group_ids) > 0 ? vpc_config.value.security_group_ids : [aws_security_group.default_sg[each.value.project_name].id]
    }
  }

  tags = local.common_tags
}
