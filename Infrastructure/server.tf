//* Server *//
resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main-public-1.id
  key_name               = aws_key_pair.mykeypair.key_name
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  tags = merge(local.common_tags,
    { Name = "facebook-reactapp"
  Application = "public" })
}