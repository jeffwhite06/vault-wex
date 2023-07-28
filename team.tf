locals {
  iam = [{
    name   = "application"
    role   = "vault-application-role", 
    policy = file("./vault-policies/team/application.hcl")
  },{
    name   = "runner"
    role   = "vault-github-runner-role", 
    policy = file("./vault-policies/team/runner.hcl")
  }]
}

resource "vault_namespace" "team" {
  namespace = vault_namespace.fabric.path
  path      = var.team
}

resource "vault_mount" "team_kv" {
  path      = "secret"
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
  name      = "shared/example"

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
  policy     = file("./vault-policies/team/admin.hcl")
}

module "team_engineering" {
  source = "./modules/team"

  team      = var.team
  team_path = vault_namespace.team.path_fq
  team_id   = module.admin_engineering.admin_group_id
  policy    = file("./vault-policies/team/team.hcl")
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

module "environments" {
  source = "./modules/environment"

  count = length(var.environments)

  environment = var.environments[count.index].name
  team_path   = vault_namespace.team.path_fq
  iam         = local.iam
  kv_mount    = vault_mount.team_kv.path
  policies    = vault_policy.iam[*].name
}