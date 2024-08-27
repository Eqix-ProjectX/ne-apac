output "hostname_vd" {
  value = module.ne.hostname_vd
}
output "hostname_vd_sec" {
  value = module.ne.hostname_vd_sec
}
output "ssh_ip_vd" {
  value = module.ne.ssh_ip_vd
}
output "ssh_ip_vd_sec" {
  value = module.ne.ssh_ip_vd_sec
}
output "uuid_pri" {
  value = module.ne.uuid_pri
}
output "uuid_sec" {
  value = module.ne.uuid_sec
}
output "vd_password" {
  value = module.ne.pass
  sensitive = true
}
output "vd_password_sec" {
  value = module.ne.pass_sec
  sensitive = true
}