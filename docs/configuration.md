## Configuration syntax

Configurations provided to the module retrieved from a configuration file (YAML-based format) with a following syntax

### Syntax

_Note: replace <<>> values with an actual configuration_

```yaml
config:
  - name: << codebuild project name >>
    description: << codebuild project description >>
    build_timeout: << codebuild project timeout >>
    badge_enabled: << codebuild project badge flag >>
    concurrent_build_limit: << codebuild project concurent build limit >>
    queued_timeout: << codebuild project queue timeout >>
    service_role:
      name: << codebuild project IAM role name >>
      policy: << codebuild project IAM policy >>
    source:
      type: NO_SOURCE
    artifacts:
      type: NO_ARTIFACTS

```

### Overview

#### config

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | AWS Codebuild project name | string | n/a | yes |
| description | AWS Codebuild project description | string | "" | no |
| build\_timeout | Number of minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out | string | "60" | no |
| badge_enabled | Generates a publicly-accessible URL for the projects build badge. | bool | false | no |
| concurrent\_build\_limit | A maximum number of concurrent builds for the project | int | 1 | no |
| queued\_timeout | Number of minutes, from 5 to 480 (8 hours), a build is allowed to be queued before it times out | string | "60" | no |

#### config.source

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| type | Type of repository that contains the source code to be built. Valid values: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET, S3, NO_SOURCE | string | "NO_SOURCE" | no |
| location | Location of the source code from git repositories or s3 | string | null | no |
| buildspec | Build specification to use for this build project's related builds | string | null | no |
| fetch\_git\_submodules| Flag to fetch Git submodules for the AWS CodeBuild build project | bool | null | no |
| insecure\_ssl | Ignore SSL warnings when connecting to source control | bool | null | no |
| git\_clone\_depth | Truncate git history to this many commits. Use 0 for a Full | int | 1 | no |
| report\_build\_status | Whether to report the status of a build's start and finish to your source provider. This option is only valid when the type is BITBUCKET or GITHUB | bool | null | no |

#### config.source.source_credentials

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| auth\_type | The type of authentication used to connect to a GitHub, GitHub Enterprise, or Bitbucket repository. Supported values: PERSONAL_ACCESS_TOKEN, BASIC_AUTH | string | n/a | yes |
| server\_type| The source provider used for this project | string | n/a | no |
| token | or GitHub or GitHub Enterprise, this is the personal access token. For Bitbucket, this is the app password | string | n/a | yes |
| username | The Bitbucket username when the authType is BASIC_AUTH | string | null | no |

#### config.service_role

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | Codebuild project IAM role name | string | n/a | yes |
| policy | Codebuild project IAM role access policy | string | n/a | yes |

#### config.vpc

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| vpc\_id | ID of the VPC within which to run builds | string | n/a | yes |
| subnets | List of subnet IDs within which to run builds | list{string} | n/a | yes |
| security\_group\_ids | Security group IDs to assign to running builds | list{string} | [] | no |

#### config.artifacts

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| type | Build output artifact's type. Valid values: CODEPIPELINE, NO_ARTIFACTS, S3 | string | "NO_ARTIFACTS" | no |
| artifact\_identifier | Artifact identifier. Must be the same specified inside the AWS CodeBuild build specification | string | null | no |
| bucket\_owner\_access | Specifies the bucket owner's access for objects that another account uploads to their Amazon S3 bucket. Valid values are NONE, READ_ONLY, and FULL | string | null | no |
| encryption | Whether to encrypt output artifacts | string | false | no |
| location | Information about the build output artifact location. If type is set to CODEPIPELINE or NO_ARTIFACTS, this value is ignored. If type is set to S3, this is the name of the output bucket | string | null | no |
| name | Name of the project | string | null | no |
| namespace\_type | Namespace to use in storing build artifacts | string | null | no |
| override\_artifact\_name | Whether a name specified in the build specification overrides the artifact name | string | null | no |
| packaging | Type of build output artifact to create | string | null | no |
| path | If type is set to S3, this is the path to the output artifact | string | null | no |

#### config.cache

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| type | Type of storage that will be used for the AWS CodeBuild project cache. Valid values: NO_CACHE, LOCAL, S3 | string | "NO_CACHE" | no |
| location | ocation where the AWS CodeBuild project stores cached resources | string | null | no |
| modes | Specifies settings that AWS CodeBuild uses to store and reuse build dependencies. Valid values: LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, LOCAL_CUSTOM_CACHE | string | null | no |

#### config.environment

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| compute_type | Information about the compute resources the build project will use. Valid values: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_2XLARGE. BUILD_GENERAL1_SMALL is only valid if type is set to LINUX_CONTAINER. When type is set to LINUX_GPU_CONTAINER, compute_type must be BUILD_GENERAL1_LARGE | string | "BUILD_GENERAL1_SMALL" | no |
| image | Docker image to use for this build project | string | "aws/codebuild/standard:5.0" | no |
| certificate | ARN of the S3 bucket, path prefix and object key that contains the PEM-encoded certificate | string | null | no |
| image\_pull\_credentials\_type | Type of credentials AWS CodeBuild uses to pull images in your build. Valid values: CODEBUILD, SERVICE_ROLE | string | "CODEBUILD" | no |
| privileged\_mode | Whether to enable running the Docker daemon inside a Docker container | bool | false | no |
| variables | A configuration block providing Codebuild project environment variables | object() | n/a | no |

#### config.environment.variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | Environment variable name | string | n/a | yes |
| value | Environement variable value | string | n/a | yes |
| type | Type of environment variable. Valid values: PARAMETER_STORE, PLAINTEXT, SECRETS_MANAGER | string | "PLAINTEXT" | no |

#### config.environment.registry_credentials

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| credential | ARN or name of credentials created using AWS Secrets Manager | string | n/a | yes |
| provider | Service that created the credentials to access a private Docker registry. Valid value: SECRETS_MANAGER | string | "SECRETS_MANAGER" | no |

#### config.logs.cloudwatch

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| group\_name | Group name of the logs in CloudWatch Logs | string | n/a | yes |
| stream\_name | Stream name of the logs in CloudWatch Logs | string | n/a | yes |
| status | Current status of logs in CloudWatch Logs for a build project. Valid values: ENABLED, DISABLED | string | "ENABLED" | no |

#### config.logs.s3

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| location | Name of the S3 bucket and the path prefix for S3 logs | string | n/a | yes |
| encryption | Whether to encrypt S3 logs | bool | false | no |
| status | Current status of logs in S3 for a build project. Valid values: ENABLED, DISABLED | string | "ENABLED" | no |
