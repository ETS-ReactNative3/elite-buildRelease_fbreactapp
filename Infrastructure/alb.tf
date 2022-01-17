//* ALB *//

resource "aws_lb" "fbreactapplb" {
  name               = join("-", [local.application.app_name, "fbreactapplb"])
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2-sg.id, aws_security_group.main-alb.id]
  subnets            = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  idle_timeout       = "60"

  access_logs {
    bucket  = aws_s3_bucket.fbreactapps3dev.bucket
    prefix  = join("-", [local.application.app_name, "fbreactapplb-s3logs"])
    enabled = true
  }
  tags = merge(local.common_tags,
    { Name = "fbreactappserver"
  Application = "public" })
}
resource "aws_lb_target_group" "fbreactapp_tglb" {
  name     = join("-", [local.application.app_name, "fbreactapptglb"])
  port     = 3000
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
resource "aws_lb_target_group_attachment" "fbreactapp_tglbat" {
  target_group_arn = aws_lb_target_group.fbreactapp_tglb.arn
  target_id        = aws_instance.server.id
  port             = 3000
}

# # ####-------- SSL Cert ------#####
resource "aws_lb_listener" "fbreactapp_lblist2" {
  load_balancer_arn = aws_lb.fbreactapplb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:us-east-1:375866976303:certificate/2bdb6ebe-4149-4e39-9bba-fa129bff471a1"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fbreactapp_tglb.arn
  }
}


####---- Redirect Rule -----####
resource "aws_lb_listener" "fbreactapp_lblist" {
  load_balancer_arn = aws_lb.fbreactapplb.arn
  port              = "3000"
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
resource "aws_s3_bucket" "fbreactapps3dev" {
  bucket = join("-", [local.application.app_name, "logdev"])
  acl    = "private"

  tags = merge(local.common_tags,
    { Name = "fbreactappserver"
  bucket = "private" })
}
resource "aws_s3_bucket_policy" "fbreactapps3dev" {
  bucket = aws_s3_bucket.fbreactapps3dev.id

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
          aws_s3_bucket.fbreactapps3dev.arn,
          "${aws_s3_bucket.fbreactapps3dev.arn}/*",
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
