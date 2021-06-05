locals {
  job_fullname         = "${var.repository_name}-${var.job_name}"
  enabled              = var.enable_module ? 1 : 0
  deploy_in_vpc        = length(var.vpc_id) > 0 ? true : false
  default_vpc_sg       = length(var.vpc_security_groups) > 0 ? false : local.deploy_in_vpc
  default_job_iam_role = length(var.job_iam_role) > 0 ? 0 : local.enabled

  common_tags = merge(var.tags, {
    Application = var.name
    Workspace   = terraform.workspace
  })
}
