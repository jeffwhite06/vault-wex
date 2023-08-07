resource "vault_mount" "kv" {
  path      = "${var.environment}/${var.kv_store}"
  namespace = var.team_path
  type      = "kv"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_v2" "example" {
  mount     = vault_mount.kv.path
  namespace = var.team_path
  name      = "example"

  data_json = jsonencode({
    username = "username",
    password = "password"
  })
}

resource "vault_policy" "env" {
  name      = var.environment
  namespace = var.team_path
  policy    = contains(["prod","stage"], var.environment) ? templatefile("${path.root}/vault-policies/env/prod.hcl", {environment = var.environment}) : templatefile("${path.root}/vault-policies/env/nonprod.hcl", {environment = var.environment})
}

resource "vault_identity_group" "env" {
  name             = var.environment
  namespace        = var.team_path
  type             = "internal"
  policies         = [vault_policy.env.name]
  member_group_ids = var.group_ids
}

resource "vault_aws_auth_backend_config_identity" "iam" {
  backend      = vault_auth_backend.iam.path
  namespace    = var.team_path
  iam_alias    = "unique_id"
  iam_metadata = ["account_id", "auth_type", "canonical_arn", "client_arn", "client_user_id", "inferred_aws_region", "inferred_entity_id", "inferred_entity_type"]
}

resource "vault_identity_entity" "iam" {
  count = length(var.iam)

  name      = "${var.environment}-${var.iam[count.index].name}-iam-role"
  namespace = var.team_path
  policies  = [var.policies[count.index]]

  metadata = {
    environment = var.environment
  }
}

resource "vault_identity_entity_alias" "iam" {
  count = length(var.iam)

  name           = module.environment_iam.role_ids[count.index]
  namespace      = var.team_path
  mount_accessor = vault_auth_backend.iam.accessor
  canonical_id   = vault_identity_entity.iam[count.index].id
}

resource "vault_auth_backend" "iam" {
  type      = "aws"
  path      = "${var.environment}/aws"
  namespace = var.team_path
}

resource "vault_aws_auth_backend_client" "iam" {
  backend    = vault_auth_backend.iam.path
  namespace  = var.team_path
  access_key = module.environment_iam.access_key
  secret_key = module.environment_iam.secret_key
}

resource "vault_aws_auth_backend_role" "app" {
  count = length(var.iam)

  backend                  = vault_auth_backend.iam.path
  namespace                = var.team_path
  role                     = module.environment_iam.role_names[count.index]
  auth_type                = "iam"
  bound_iam_principal_arns = [module.environment_iam.roles[count.index]]
  resolve_aws_unique_ids   = true
  token_policies           = ["default"]

  depends_on = [vault_aws_auth_backend_client.iam]
}