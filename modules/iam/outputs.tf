output "access_key" {
  value = aws_iam_access_key.vault.id
}

output "secret_key" {
  value     = aws_iam_access_key.vault.secret
  sensitive = true
}

output "roles" {
  value = length(aws_iam_role.vault) > 0 ? aws_iam_role.vault[*].arn : null
}

output "role_names" {
  value = length(aws_iam_role.vault) > 0 ? aws_iam_role.vault[*].name : null
}

output "role_ids" {
  value = length(aws_iam_role.vault) > 0 ? aws_iam_role.vault[*].unique_id : null
}

output "instance_profiles" {
  value = length(aws_iam_instance_profile.vault) > 0 ? aws_iam_instance_profile.vault[*].name : null
}