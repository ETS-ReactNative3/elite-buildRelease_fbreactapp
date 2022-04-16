//* Server *//
resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main-public-1.id
  key_name               = aws_key_pair.serverkey.key_name
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  user_data_base64       = data.cloudinit_config.userdata.rendered
  lifecycle {
    ignore_changes = [ami, user_data_base64]
  }
  tags = merge(local.common_tags,
    { Name = "fb-reactapp"
  Application = "public" })
}

resource "aws_instance" "server_jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main-public-1.id
  key_name               = aws_key_pair.serverkey.key_name
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  user_data_base64       = data.cloudinit_config.userdata_jenkins.rendered
  lifecycle {
    ignore_changes = [ami, user_data_base64]
  }
  tags = merge(local.common_tags,
    { Name = "jenkins"
  Application = "public" })
}