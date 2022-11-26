data "aws_caller_identity" "current" {}

variable "project_name" {
  description = "Project Name"
  default     = "supersecret"
}

variable "host_name" {
  description = "Host Name"
  default     = "super-secret-1"
}

variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "aws_az" {
  description = "AWS Zone"
  type        = string
  default     = "us-east-1a"
}

variable "key_name" {
  description = "SSH Key name"
  type        = string
  default     = "supersecret-key"
}

variable "rules" {
  type = list(object({
    port        = number
    proto       = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      port        = 80
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 2020
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]


}


locals {
  userdata = {
    project_name    = var.project_name,
    jupyter_passwd  = random_password.jupy_string.result,
    account_id      = data.aws_caller_identity.current.account_id
  }
}
