locals {
  iam = [{
    name   = "application"
    policy = templatefile("./vault-policies/team/application.hcl", {
      secret = local.shared_kv
    })
  },{
    name   = "runner"
    policy = templatefile("./vault-policies/team/runner.hcl", {
      secret = local.shared_kv
    })
  }]
}

resource "vault_namespace" "team" {
  namespace = vault_namespace.fabric.path
  path      = var.team
}

resource "vault_mount" "team_kv" {
  path      = "${local.shared_kv}/${local.kv_store}"
  namespace = vault_namespace.team.path_fq
  type      = "kv"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_backend_v2" "team_kv" {
  mount     = vault_mount.team_kv.path
  namespace = vault_namespace.team.path_fq
}

resource "vault_kv_secret_v2" "team" {
  mount     = vault_mount.team_kv.path
  namespace = vault_namespace.team.path_fq
  name      = "example"

  data_json = jsonencode({
    username = "username",
    password = "password"
  })
}

module "team_admins" {
  source = "./modules/team"

  team       = var.admin_team
  team_path  = vault_namespace.team.path_fq
  team_id    = module.admin_admins.admin_group_id
  policy     = templatefile("./vault-policies/team/admin.hcl", {
    store = local.kv_store
  })
}

module "team_engineering" {
  source = "./modules/team"

  team      = var.team
  team_path = vault_namespace.team.path_fq
  team_id   = module.admin_engineering.admin_group_id
  policy    = templatefile("./vault-policies/team/team.hcl", {
    secret = local.shared_kv
    store  = local.kv_store
  })
}

module "team_security" {
  source = "./modules/team"

  team      = var.security_team
  team_path = vault_namespace.team.path_fq
  team_id   = module.admin_security.admin_group_id
  policy    = file("./vault-policies/team/security.hcl")
}

resource "vault_policy" "iam" {
  count = length(local.iam)

  name      = local.iam[count.index].name
  namespace = vault_namespace.team.path_fq
  policy    = local.iam[count.index].policy
}

module "prod" {
  source = "./modules/environment"

  environment = var.environments[0].name
  team_path   = vault_namespace.team.path_fq
  iam         = local.iam
  policies    = vault_policy.iam[*].name
  kv_store    = local.kv_store
}

module "dev" {
  source = "./modules/environment"

  providers = {
    aws = aws.dev
  }

  environment = var.environments[1].name
  team_path   = vault_namespace.team.path_fq
  iam         = local.iam
  policies    = vault_policy.iam[*].name
  kv_store    = local.kv_store
}