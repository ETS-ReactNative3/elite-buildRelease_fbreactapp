/* security group */
resource "aws_security_group" "ec2-sg" {
  vpc_id      = aws_vpc.main.id
  name        = "public web react sg"
  description = "security group Ec2-server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#   ingress {
#     from_port       = 8080
#     to_port         = 8080
#     protocol        = "tcp"
#     security_groups = [aws_security_group.main-alb.id]
#   }

#   ingress {
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [aws_security_group.main-alb.id]
#   }
#   /////sonarqubeSG
#   ingress {
#     from_port       = 4040
#     to_port         = 4040
#     protocol        = "tcp"
#     security_groups = [aws_security_group.main-alb.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  tags = merge(local.common_tags,
  { Name = "facebookapp-react" })
}