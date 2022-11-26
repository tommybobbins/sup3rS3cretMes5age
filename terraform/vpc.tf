provider "aws" {
  region = var.aws_region
}

data "aws_ssm_parameter" "ami_id" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                            = "${var.project_name}-vpc"
  cidr                            = "10.23.0.0/16"
  azs                             = ["${var.aws_az}"]
  public_subnets                  = ["10.23.23.0/24"]
  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true
  public_subnet_ipv6_prefixes     = [0, 1]

}


resource "aws_security_group" "ec2-sg" {
  vpc_id = module.vpc.vpc_id
  name   = join("_", ["sg", module.vpc.vpc_id])
  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-dynamic-SG"
  }
}

