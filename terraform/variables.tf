data "aws_caller_identity" "current" {}

variable "project_name" {
  description = "Project Name"
  default     = "supersecret"
}

variable "host_name" {
  description = "Host Name"
  default     = "super-secret-1"
}

locals {
  region           = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
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
      port        = 443
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]


}


locals {
  userdata = {
    project_name    = var.project_name,
    account_id      = data.aws_caller_identity.current.account_id
  }
}

data "aws_acm_certificate" "supersecret" {
  domain   = "chapelramblers.org"
  statuses = ["ISSUED"]
}

