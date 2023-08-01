locals {
  admin_namespace = "admin"
  shared_kv       = "shared"
  kv_store        = "kvv2"
}

module "admin_iam" {
  source = "./modules/iam"

  names = [local.admin_namespace]
  layer = local.admin_namespace
}

resource "vault_github_auth_backend" "github" {
  organization = var.github_org
}

resource "vault_auth_backend" "iam" {
  type = "aws"
}

resource "vault_aws_auth_backend_client" "iam" {
  backend    = vault_auth_backend.iam.path
  access_key = module.admin_iam.access_key
  secret_key = module.admin_iam.secret_key
}

resource "vault_mount" "admin_kv" {
  path = "${local.admin_namespace}/${local.kv_store}"
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
  policy               = templatefile("./vault-policies/admin/admin.hcl", {
    secret = local.admin_namespace
  })
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

resource "vault_aws_auth_backend_role" "app" {
  backend                  = vault_auth_backend.iam.path
  role                     = "admin"
  auth_type                = "iam"
  bound_iam_principal_arns = [module.admin_iam.roles[0]]
  resolve_aws_unique_ids   = true
  token_policies           = ["default", module.admin_admins.policy]

  depends_on = [vault_aws_auth_backend_client.iam]
}

module "instance" {
  source = "./modules/instance"
  
  names             = [local.admin_namespace]
  instance_profiles = [module.admin_iam.instance_profiles[0]]
}