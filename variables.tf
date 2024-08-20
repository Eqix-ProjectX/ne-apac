variable "core_count" {}
variable "metro_code" {}
variable "notifications" {}
variable "package_code" {}
variable "sec_metro_code" {}
variable "type_code" {}
variable "ver" {}
variable "account_number" {}
variable "sec_account_number" {}
variable "username" {}
variable "key_name" {}
variable "acl_template_id" {}
variable "private_key" {
  type      = string
  sensitive = true
}
variable "project_id" {}
