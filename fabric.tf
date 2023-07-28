resource "vault_namespace" "fabric" {
  path = var.fabric
}

resource "vault_mount" "fabric_kv" {
  path      = "secret"
  namespace = vault_namespace.fabric.path_fq
  type      = "kv"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_backend_v2" "fabric_kv" {
  mount     = vault_mount.fabric_kv.path
  namespace = vault_namespace.fabric.path_fq
}

resource "vault_kv_secret_v2" "fabric" {
  mount     = vault_mount.fabric_kv.path
  namespace = vault_namespace.fabric.path_fq
  name      = "example"

  data_json = jsonencode({
    username = "username",
    password = "password"
  })
}

module "fabric_admins" {
  source = "./modules/fabric"

  fabric      = var.fabric
  fabric_path = vault_namespace.fabric.path_fq
  team        = var.admin_team
  team_id     = module.admin_admins.admin_group_id
  policy      = file("./vault-policies/fabric/admin.hcl")
}

module "fabric_engineering" {
  source = "./modules/fabric"

  fabric      = var.fabric
  fabric_path = vault_namespace.fabric.path_fq
  team        = var.team
  team_id     = module.admin_engineering.admin_group_id
}

module "fabric_security" {
  source = "./modules/fabric"

  fabric      = var.fabric
  fabric_path = vault_namespace.fabric.path_fq
  team        = var.security_team
  team_id     = module.admin_security.admin_group_id
  policy      = file("./vault-policies/fabric/security.hcl")
}