# CodeDeploy Configuration

#------------------------------------------------------------------------------
# CodeDeploy IAM Role
#------------------------------------------------------------------------------
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.project_name}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-codedeploy-role"
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

#------------------------------------------------------------------------------
# CodeDeploy Application
#------------------------------------------------------------------------------
resource "aws_codedeploy_app" "app" {
  name             = "${var.project_name}-app"
  compute_platform = "Server"
}

#------------------------------------------------------------------------------
# CodeDeploy Deployment Group
#------------------------------------------------------------------------------
resource "aws_codedeploy_deployment_group" "app" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = "${var.project_name}-deployment-group"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  autoscaling_groups = [aws_autoscaling_group.app.name]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.app.name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  # Blue/Green deployment settings (optional, for more advanced deployments)
  # blue_green_deployment_config {
  #   deployment_ready_option {
  #     action_on_timeout = "CONTINUE_DEPLOYMENT"
  #   }
  #   terminate_blue_instances_on_deployment_success {
  #     action = "TERMINATE"
  #     termination_wait_time_in_minutes = 5
  #   }
  # }
}
