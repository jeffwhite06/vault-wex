locals {
  admin_namespace = "admin"
}

resource "vault_github_auth_backend" "github" {
  organization = var.github_org
}

resource "vault_github_team" "team" {
  backend = vault_github_auth_backend.github.id
  team    = var.team
}

resource "vault_namespace" "fabric" {
  path = var.fabric
}