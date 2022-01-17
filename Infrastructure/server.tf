//* Server *//
resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main-public-1.id
  key_name               = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDsSYI8NZixzmCEAebCO+30zO/yyMdNh6V95N5zz05mzNXAulCp6splHhMFtgvnRKVmWCXEUhwEFfZoosy/l4Wq0u56iTgLAtqfb+x2RG3oxy3TMhQiwQHisiOs3+ae3QKIZL/lzis2jDw7L99MF9/TSLdAZ8RbU+0MOAqiiqE1c2pKknJnTglRRYP0Ce97wKv5vWmrp95peZC0XlGMCjK8FdZ+WwuUeIg6oWrs5B2xJAFzEVXict7lZAv6dftka03jA7XXbMc5tEY0rtfyL1FiRweg9vPK4JuG+zOr2CxZFjbHdEM9YPoppkGH7fX4O9yFyXKHk2sMyH+okstHos52Ok9m4zQXDgVsRISisG8wEmViSiwmSLkfYxJbNZUXgg6MqRfh/6A7lhadqSDGqRQL7CVedHpzp1/X84ixqBHUpFKj4gl0ULYuw98Ty86AMIhc/cIkglzzSxoxAJjM+Qk8BAl9BLorP5Hwv6zTfD69sn0sLGoFJgVgUWcPAKMNY40= lbena@LAPTOP-QB0DU4OG"
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  tags = merge(local.common_tags,
    { Name = "facebook-reactapp"
  Application = "public" })
}