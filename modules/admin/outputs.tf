output "admin_group_id" {
  value = vault_identity_group.admin.id
}

output "admin_group_name" {
  value = vault_identity_group.admin.name
}

output "policy" {
  value = var.policy == null ? null : vault_policy.admin[0].name
}