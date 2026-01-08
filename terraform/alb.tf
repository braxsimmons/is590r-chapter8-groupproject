# Application Load Balancer

#------------------------------------------------------------------------------
# Application Load Balancer
#------------------------------------------------------------------------------
resource "aws_lb" "app" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false # Set to true for production

  tags = {
    Name = "${var.project_name}-alb"
  }
}

#------------------------------------------------------------------------------
# Target Group
#------------------------------------------------------------------------------
resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

#------------------------------------------------------------------------------
# HTTP Listener
#------------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Note: For HTTPS, uncomment and configure the following:
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.app.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = var.certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app.arn
#   }
# }
