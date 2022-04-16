//* ALB *//

resource "aws_lb" "jenkinslb" {
  name               = join("-", [local.application.app_name, "jenkinslb"])
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2-sg.id, aws_security_group.main-alb.id]
  subnets            = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  idle_timeout       = "60"

  access_logs {
    bucket  = aws_s3_bucket.jenkinss3dev.bucket
    prefix  = join("-", [local.application.app_name, "jenkinslb-s3logs"])
    enabled = true
  }
  tags = merge(local.common_tags,
    { Name = "jenkinsserver"
  Application = "public" })
}
resource "aws_lb_target_group" "jenkins_tglb" {
  name     = join("-", [local.application.app_name, "jenkinstglb"])
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    timeout             = "5"
    interval            = "30"
    matcher             = "200"
  }
}
resource "aws_lb_target_group_attachment" "jenkins_tglbat" {
  target_group_arn = aws_lb_target_group.jenkins_tglb.arn
  target_id        = aws_instance.server_jenkins.id
  port             = 8080
}

# # ####-------- SSL Cert ------#####
resource "aws_lb_listener" "jenkins_lblist2" {
  load_balancer_arn = aws_lb.jenkinslb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.jenkinscert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tglb.arn
  }
}


####---- Redirect Rule -----####
resource "aws_lb_listener" "jenkins_lblist" {
  load_balancer_arn = aws_lb.jenkinslb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

//* ALB BUCKET *//
########------- S3 Bucket -----------####
resource "aws_s3_bucket" "jenkinss3dev" {
  bucket = join("-", [local.application.app_name, "jenkinslogs"])
  acl    = "private"

  tags = merge(local.common_tags,
    { Name = "jenkinsserver"
  bucket = "private" })
}
resource "aws_s3_bucket_policy" "jenkinss3dev" {
  bucket = aws_s3_bucket.jenkinss3dev.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "Allow"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.jenkinss3dev.arn,
          "${aws_s3_bucket.jenkinss3dev.arn}/*",
        ]
        Condition = {
          NotIpAddress = {
            "aws:SourceIp" = "8.8.8.8/32"
          }
        }
      },
    ]
  })
}
