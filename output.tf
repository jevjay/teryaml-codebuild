output "codebuild_job_arn" {
  value = aws_codebuild_project.job.*.arn
}

output "codebuild_job_name" {
  value = aws_codebuild_project.job.*.id
}
