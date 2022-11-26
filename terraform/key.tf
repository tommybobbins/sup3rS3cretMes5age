resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh-key.public_key_openssh

}

resource "local_sensitive_file" "pem_file" {
  filename             = pathexpand("./${var.project_name}.pem")
  file_permission      = "600"
  directory_permission = "700"
  content              = tls_private_key.ssh-key.private_key_pem
  provisioner "local-exec" {
    command = "ssh-keygen -y -f ${var.project_name}.pem  > ${var.project_name}.pub"
  }
}
