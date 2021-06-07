# terraforest-codebuild

![Terraforest](./img/logo.png)

Terraform module used to configure AWS Codebuild job and its supporting resources.

# Usage

Create a simple Codebuild job integrated with AWS CodeCommit as a source

```hcl
module "codecommit_job" {
  source  = "git::https://github.com/jevjay/terraforest-codebuild.git?ref=v0.0.1"

  repository_name = "my-repository"
  repository_url  = "https://git-codecommit.us-east-2.amazonaws.com/v1/repos/my-repository"
  job_name        = "my-job"
  buildspec_file  = "buildspec.yml"
  source_type     = "CODECOMMIT"
}
```

Create a simple Codebuild job integrated with Github as a source

```hcl
module "github_job" {
  source  = "git::https://github.com/jevjay/terraforest-codebuild.git?ref=v0.0.1"

  repository_name = "my-repository"
  repository_url  = "https://github.com/jevjay/my-repository.git"
  job_name        = "my-job"
  buildspec_file  = "buildspec.yml"
  source_type     = "GITHUB"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| repository\_name | Repository name to which Codebuild Job should be linked | string | n/a | yes |
| repository\_url | Repository clone URL | string | n/a | yes |
| job\_name | Codebuild job name | string | n/a | yes |
| buildspec\_file | Buildspec file path (within linked repository) which Codebuild job should read for instructions | string | n/a | yes |
| source\_type | Type of repository that contains the source code to be built. Valid values: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET, S3, NO_SOURCE | string | n/a | yes |
| enable\_module | Flag to enable/disable module without removing its definition from a parent terraform | bool | false | no |
| source\_creds\_token | Used source credentials token. For GitHub or GitHub Enterprise, this is the personal access token. For Bitbucket, this is the app password | string | "" | no |
| job\_build\_timeout | Codebuild job timeout. Value should be set between 1-8 hour(s) and specified in minutes | string | "60" | no |
| job\_build\_compute\_type | Codebuild job compute size | string | "BUILD_GENERAL1_SMALL" | no |
| job\_build\_image | Codebuild job docker image runtime | string | "aws/codebuild/standard:3.0" | no |
| job\_build\_privileged\_override | Flag to enable sudo right for Codebuild job | bool | false | no |
| vpc\_id | VPC ID in which Codebuild Job should be deployed | string | "" | no |
| vpc\_subnets | Assigned VPC subnets, from which Codebuild Job should receive an IP address during its run | list(any) | \[\] | no |
| vpc\_security\_groups | Assigned VPC security group attached to Codebuild Job | list(any) | \[\] | no |
| job\_iam\_role | Codebuild Job assigned IAM role providing permissions to interact with AWS services | string | "" | no |
| enable\_docker\_cache | Enable local docker layer caching for Codebuild Job | bool | false | no |
| enable\_s3\_cache | Enable S3 based caching for Codebuild Job | bool | false | no |
| s3\_cache\_location | S3 cache location. Only provide this value if S3 cache was enabled | string | "" | no |
| enable\_artifacts | Enable build artifacts sharing | bool | false | no |
| artifacts\_type | Build output artifact's type. Valid values: CODEPIPELINE, NO_ARTIFACTS, S3 | string | "S3" | no |
| tags | Additional user defiend resoirce tags | map{any} | \{\} | no |

## Outputs

| Name | Description |
|------|-------------|
| codebuild\_job\_arn | Created AWS Codebuild job ARN value |
| codebuild\_job\_name | Created AWS Codebuild job full name |

## Authors

Originally created by [Jev Jay](https://github.com/jevjay)
Module managed by [Jev Jay](https://github.com/jevjay).

## License

Apache 2.0 licensed. See `LICENSE.md` for full details.
