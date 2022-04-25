locals {
  # === CONFIG file parsing ===

  file_config = try(yamldecode(file(var.config))["config"], [])
  raw_config  = yamldecode(var.raw_config)["config"]
  # Overwrite configurations (if applicable)
  config = length(local.raw_config) > 0 ? local.raw_config : local.file_config

  # === PROJECT ===

  project = try(flatten([
    for i, config in local.config : {
      project_name           = config.name
      description            = lookup(config, "description", "")
      build_timeout          = lookup(config, "build_timeout", "60")
      badge_enabled          = lookup(config, "badge_enabled", false)
      concurrent_build_limit = lookup(config, "concurrent_build_limit", 1)
      queued_timeout         = lookup(config, "queued_timeout", "60")
    }
  ]), {})

  # === SOURCE ===

  source = try(flatten([
    for i, config in local.config : {
      project_name         = config.name
      type                 = lookup(config.source, "type", "NO_SOURCE")
      location             = lookup(config.source, "location", null)
      buildspec            = lookup(config.source, "buildspec", null)
      fetch_git_submodules = lookup(config.source, "fetch_git_submodules", null)
      insecure_ssl         = lookup(config.source, "insecure_ssl", null)
      git_clone_depth      = lookup(config.source, "git_clone_depth", 1)
      report_build_status  = lookup(config.source, "report_build_status", null)
    }
  ]), {})

  source_credentials = try(flatten([
    for i, config in local.config : {
      project_name = config.name
      source_type  = lookup(config.source, "type", "NO_SOURCE")
      auth_type    = lookup(lookup(config.source, "credentials", {}), "auth_type", null)
      server_type  = lookup(lookup(config.source, "credentials", {}), "server_type", null)
      token        = lookup(lookup(config.source, "credentials", {}), "token", null)
      username     = lookup(lookup(config.source, "credentials", {}), "username", null)
    }
  ]), {})

  # === IAM ===

  service_role = flatten([
    for i, config in local.config : {
      project_name = config.name
      name         = lookup(config.service_role, "name", null)
      policy       = lookup(config.service_role, "policy", null)
  }])

  # === VPC ===

  vpc_config = try(flatten([
    for i, config in local.config : {
      project_name       = config.name
      vpc_id             = lookup(config.vpc, "id", null)
      subnets            = lookup(config.vpc, "subnets", null)
      security_group_ids = lookup(config.vpc, "security_group_ids", [])
  }]), {})

  # === ARTIFACTS & CACHE ===

  artifacts = try(flatten([
    for i, config in local.config : {
      project_name           = config.name
      type                   = lookup(config.artifacts, "type", "NO_ARTIFACTS")
      artifact_identifier    = lookup(config.artifacts, "identifier", null)
      bucket_owner_access    = lookup(config.artifacts, "bucket_owner_access", null)
      encryption_disabled    = !lookup(config.artifacts, "encryption", true)
      location               = lookup(config.artifacts, "location", null)
      name                   = lookup(config.artifacts, "name", null)
      namespace_type         = lookup(config.artifacts, "namespace_type", null)
      override_artifact_name = lookup(config.artifacts, "override_artifact_name", null)
      packaging              = lookup(config.artifacts, "packaging", null)
      path                   = lookup(config.artifacts, "path", null)
    }
  ]), {})

  cache = try(flatten([
    for i, config in local.config : {
      project_name = config.name
      type         = lookup(config.cache, "type", "NO_CACHE")
      location     = lookup(config.cache, "location", null)
      modes        = lookup(config.cache, "modes", null)
    }
  ]), {})

  # === ENVIRONMENT ===

  environment = try(flatten([
    for i, config in local.config : {
      project_name                = config.name
      compute_type                = lookup(config.environment, "compute_type", "BUILD_GENERAL1_SMALL")
      image                       = lookup(config.environment, "image", "aws/codebuild/standard:5.0")
      type                        = lookup(config.environment, "type", "LINUX_CONTAINER")
      certificate                 = lookup(config.environment, "certificate", null)
      image_pull_credentials_type = lookup(config.environment, "image_pull_credentials_type", "CODEBUILD")
      privileged_mode             = lookup(config.environment, "privileged_mode", false)
    }]), flatten([
    for i, config in local.config : {
      project_name                = config.name
      type                        = "LINUX_CONTAINER"
      compute_type                = "BUILD_GENERAL1_SMALL"
      image_pull_credentials_type = "CODEBUILD"
      image                       = "aws/codebuild/standard:5.0"
      privileged_mode             = false
      certificate                 = null
    }
  ]))

  environment_variables = try(flatten([
    for config in local.config : [
      for v in lookup(config.environment, "variables", []) : {
        name  = v.name
        value = v.value
        type  = v.type
      }
    ]
  ]), {})

  registry_credentials = try(flatten([
    for i, config in local.config : [
      for j, environment_config in config.environment : [
        for k, registry_creds in environment_config.registry_credentials : {
          credential          = registry_creds.credential
          credential_provider = lookup(registry_creds, "provider", "SECRETS_MANAGER")
        }
      ]
    ]
  ]), {})

  # === LOGS ===

  clodwatch_logs = try(flatten([
    for i, config in local.config : [
      for j, logs_config in config.logs : [
        for k, cloudwatch in logs_config.cloudwatch : {
          project_name = config.name
          group_name   = cloudwatch.group_name
          stream_name  = cloudwatch.stream_name
          status       = lookup(cloudwatch, "status", "ENABLED")
        }
      ]
    ]
  ]), {})

  s3_logs = try(flatten([
    for i, config in local.config : [
      for j, logs_config in config.logs : [
        for k, s3 in logs_config.s3 : {
          project_name        = config.name
          location            = s3.location
          encryption_disabled = !lookup(s3, "encryption", true)
          status              = lookup(s3, "status", "ENABLED")
        }
      ]
    ]
  ]), {})

  # === FLAGS ===

  git_submodules_support = [
    "CODECOMMIT",
    "GITHUB",
    "GITHUB_ENTERPRISE",
  ]

  git_source_credentials_support = [
    "GITHUB",
    "GITHUB_ENTERPRISE",
    "BITBUCKET"
  ]

  common_tags = merge(var.shared_tags, {
    Terraformed = true
  })
}
