locals {
  admin_namespace = "admin"
}

resource "vault_github_auth_backend" "github" {
  organization = var.github_org
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

module "admin_admins" {
  source = "./modules/admin"

  team                 = var.admin_team
  github_auth_id       = vault_github_auth_backend.github.id
  github_auth_accessor = vault_github_auth_backend.github.accessor
  policy               = file("./vault-policies/admin/admin.hcl")
}

module "admin_engineering" {
  source = "./modules/admin"

  team                 = var.team
  github_auth_id       = vault_github_auth_backend.github.id
  github_auth_accessor = vault_github_auth_backend.github.accessor
}

module "admin_security" {
  source = "./modules/admin"

  team                 = var.security_team
  github_auth_id       = vault_github_auth_backend.github.id
  github_auth_accessor = vault_github_auth_backend.github.accessor
  policy               = file("./vault-policies/admin/security.hcl")
}