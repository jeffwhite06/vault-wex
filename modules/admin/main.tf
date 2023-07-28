resource "vault_github_team" "admin" {
  backend = var.github_auth_id
  team    = var.team
}

resource "vault_policy" "admin" {
  count = var.policy == null ? 0 : 1

  name   = var.team
  policy = var.policy
}

resource "vault_identity_group" "admin" {
  name     = var.team
  type     = "external"
  policies = length(vault_policy.admin) > 0 ? [vault_policy.admin[0].name] : null
}

resource "vault_identity_group_alias" "admin" {
  name           = var.team
  mount_accessor = var.github_auth_accessor
  canonical_id   = vault_identity_group.admin.id
}