resource "aws_instance" "supersecret" {
  ami       = data.aws_ssm_parameter.ami_id.value
  subnet_id = module.vpc.public_subnets[0]
  #ipv6_cidr_block                 = cidrsubnet(module.vpc.ipv6_cidr_block, 8, 1)
  instance_type   = "t3.nano"
  security_groups = [aws_security_group.ec2-sg.id]
  #user_data       = fileexists("userdata.sh") ? file("userdata.sh") : null
  #user_data            = data.template_file.init.rendered
  user_data            = base64encode(templatefile("userdata.sh", local.userdata))
  iam_instance_profile = aws_iam_instance_profile.ec2_access_role.name
  key_name             = aws_key_pair.generated_key.key_name
  tags = {
    Name            = var.host_name
  }
    root_block_device {
     volume_type = "gp3"
     volume_size = 15 
     encrypted   = true
   }

}

# Removed as using SSM for console access
#Create key-pair for logging into EC2
resource "aws_key_pair" "webserver-key" {
  key_name   = "webserver-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

