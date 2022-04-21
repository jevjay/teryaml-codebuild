output "codebuild_project_arn" {
  value = [
    for project in aws_codebuild_project.job : project.arn
  ]
}

output "codebuild_project_name" {
  value = [
    for project in aws_codebuild_project.job : project.id
  ]
}
