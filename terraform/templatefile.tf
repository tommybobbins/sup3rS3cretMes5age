resource "random_password" "jupy_string" {
  length  = 16
  special = false
  #  override_special = "/@£$"
}
