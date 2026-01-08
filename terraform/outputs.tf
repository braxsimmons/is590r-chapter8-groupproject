# Outputs for the infrastructure

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name (use this to access your app)"
  value       = aws_lb.app.dns_name
}

output "alb_url" {
  description = "Application URL"
  value       = "http://${aws_lb.app.dns_name}"
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS database address (hostname only)"
  value       = aws_db_instance.main.address
}

output "codedeploy_app_name" {
  description = "CodeDeploy application name"
  value       = aws_codedeploy_app.app.name
}

output "codedeploy_deployment_group" {
  description = "CodeDeploy deployment group name"
  value       = aws_codedeploy_deployment_group.app.deployment_group_name
}

output "codepipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.app.name
}

output "github_connection_arn" {
  description = "GitHub CodeStar connection ARN (needs to be activated in AWS Console)"
  value       = aws_codestarconnections_connection.github.arn
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}

output "s3_artifact_bucket" {
  description = "S3 bucket for pipeline artifacts"
  value       = aws_s3_bucket.pipeline_artifacts.bucket
}
