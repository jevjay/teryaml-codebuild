# --- Required vars ---

variable "repository_name" {
  type        = string
  description = "Repository name to which Codebuild Job should be linked"
}

variable "repository_url" {
  type        = string
  description = "Repository clone URL"
}

variable "job_name" {
  type        = string
  description = "Codebuild job name"
}

variable "buildspec_file" {
  type        = string
  description = "Buildspec file path (within linked repository) which Codebuild job should read for instructions"
}

variable "source_type" {
  type        = string
  description = "Type of repository that contains the source code to be built. Valid values: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET, S3, NO_SOURCE."
}

# --- Optional vars ---

variable "enable_module" {
  default     = false
  description = "Flag to enable/disable module without removing its definition from a parent terraform"
}

variable "source_creds_token" {
  type        = string
  description = "Used source credentials token. For GitHub or GitHub Enterprise, this is the personal access token. For Bitbucket, this is the app password"
  default     = ""
}

variable "job_build_timeout" {
  type        = string
  description = "Codebuild job timeout. Value should be set between 1-8 hour(s)"
  default     = "60"
}

variable "job_build_compute_type" {
  type        = string
  description = "Codebuild job compute size"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "job_build_image" {
  type        = string
  description = "Codebuild job docker image runtime"
  default     = "aws/codebuild/standard:3.0"
}

variable "job_build_privileged_override" {
  description = "Flag to enable sudo right for Codebuild job"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID in which Codebuild Job should be deployed"
  default     = ""
}

variable "vpc_subnets" {
  type        = list(any)
  description = "Assigned VPC subnets, from which Codebuild Job should receive an IP address during its run"
  default     = []
}

variable "vpc_security_groups" {
  type        = list(any)
  description = "Assigned VPC security group attached to Codebuild Job"
  default     = []
}

variable "job_iam_role" {
  type        = string
  description = "Codebuild Job assigned IAM role providing permissions to interact with AWS services"
  default     = ""
}

variable "enable_docker_cache" {
  description = "Enable local docker layer caching for Codebuild Job"
  default     = false
}

variable "enable_s3_cache" {
  description = "Enable S3 based caching for Codebuild Job"
  default     = false
}

variable "s3_cache_location" {
  type        = string
  description = "S3 cache location. Only provide this value if S3 cache was enabled"
  default     = ""
}

variable "enable_artifacts" {
  description = "Enable build artifacts sharing"
  default     = false
}

variable "artifacts_type" {
  type        = string
  description = "Build output artifact's type. Valid values: CODEPIPELINE, NO_ARTIFACTS, S3"
  default     = "S3"
}

variable "tags" {
  type        = map(any)
  description = "Additional user defiend resoirce tags"
  default     = {}
}
