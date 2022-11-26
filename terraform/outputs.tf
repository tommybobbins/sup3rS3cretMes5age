output "Web-Server-URL" {
  description = "Web-Server-URL"
  value       = join("", ["https://", aws_instance.my-instance.public_ip])
}

output "Time-Date" {
  description = "Date/Time of Execution"
  value       = timestamp()
}

output "SSH-string" {
  description = "Web-Server-URL"
  value       = join("", ["ssh -i ${var.project_name}.pem -oPort=2020 ec2-user@", aws_instance.my-instance.public_ip])
}

output "volume-id" {
  description = "Describe volumes"
  value       = join("", ["aws ec2 modify-volume --size=10 --volume-id ", aws_instance.my-instance.root_block_device[0].volume_id, " --region ", var.aws_region])
}

output "jupyter-token" {
  description = "Jupyter Notebook Token"
  value       = nonsensitive(random_password.jupy_string.result)
}
