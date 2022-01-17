//* ALB *//
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
  target_id        = aws_instance.fbreactappserver.id
  port             = 3000
}

# # ####-------- SSL Cert ------#####
# resource "aws_lb_listener" "fbreactapp_lblist2" {
#   load_balancer_arn = aws_lb.fbreactapplb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn   = "arn:aws:acm:us-east-1:375866976303:certificate/f3e1c14c-94cb-4c7f-b150-df5996c52f18"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.fbreactapp_tglb.arn
#   }
# }


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
