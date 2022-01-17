#IAM
resource "aws_iam_role" "fbreactapp_role" {
  name = join("-", [local.application.app_name, "fbreactapprole"])

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(local.common_tags,
    { Name = "fbreactappserver"
  Role = "fbreactapprole" })
}

#######------- IAM Role ------######
resource "aws_iam_role_policy" "fbreactapp_policy" {
  name = join("-", [local.application.app_name, "fbreactapppolicy"])
  role = aws_iam_role.fbreactapp_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
