locals {
  admin_namespace = "admin"
}

resource "vault_github_auth_backend" "github" {
  organization = var.github_org
}

resource "vault_github_team" "admin" {
  backend = vault_github_auth_backend.github.id
  team    = var.team
}

resource "vault_identity_group" "admin" {
  name     = "github"
  type     = "external"
  policies = [vault_policy.admin.name]
}

resource "vault_identity_group_alias" "admin" {
  name           = var.team
  mount_accessor = vault_github_auth_backend.github.accessor
  canonical_id   = vault_identity_group.admin.id
}

resource "vault_mount" "admin_kv" {
  path = "secret"
  type = "kv"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_backend_v2" "admin_kv" {
  mount = vault_mount.admin_kv.path
}

resource "vault_kv_secret_v2" "admin" {
  mount = vault_mount.admin_kv.path
  name  = "example"

  data_json = jsonencode({
    username = "username",
    password = "password"
  })
}

resource "vault_policy" "admin" {
  name = "admin"

  policy = <<EOT
path "secret/*" {
  capabilities = ["read","list"]
}
EOT
}