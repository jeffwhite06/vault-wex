resource "vault_kv_secret_v2" "example" {
  mount     = var.kv_mount
  namespace = var.team_path
  name      = "${var.environment}/example"

  data_json = jsonencode({
    username = "username",
    password = "password"
  })
}

# namespace is broken on this resource - need to provision manually
# resource "vault_aws_auth_backend_config_identity" "iam" {
#   backend      = vault_auth_backend.iam.path
#   namespace    = var.team_path
#   iam_alias    = "unique_id"
#   iam_metadata = ["account_id", "auth_type", "canonical_arn", "client_arn", "client_user_id", "inferred_aws_region", "inferred_entity_id", "inferred_entity_type"]
# }

resource "vault_identity_entity" "iam" {
  count = length(var.iam)

  name      = "${var.environment}-${var.iam[count.index].name}-iam-role"
  namespace = var.team_path

  metadata = {
    environment = var.environment
  }
}

resource "vault_identity_entity_alias" "iam" {
  count = length(var.iam)

  name           = aws_iam_role.vault[count.index].unique_id
  namespace      = var.team_path
  mount_accessor = vault_auth_backend.iam.accessor
  canonical_id   = vault_identity_entity.iam[count.index].id
}

resource "vault_auth_backend" "iam" {
  type      = "aws"
  namespace = var.team_path
}

resource "vault_aws_auth_backend_client" "iam" {
  backend    = vault_auth_backend.iam.path
  namespace  = var.team_path
  access_key = aws_iam_access_key.vault.id
  secret_key = aws_iam_access_key.vault.secret
}

resource "vault_aws_auth_backend_role" "app" {
  count = length(var.iam)

  backend                  = vault_auth_backend.iam.path
  namespace                = var.team_path
  role                     = var.iam[count.index].role
  auth_type                = "iam"
  bound_iam_principal_arns = [aws_iam_role.vault[count.index].arn]
  resolve_aws_unique_ids   = true
  token_policies           = [var.policies[count.index]]

  depends_on = [vault_aws_auth_backend_client.iam]
}