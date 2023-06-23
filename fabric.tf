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

resource "vault_policy" "fabric" {
  name      = "fabric"
  namespace = vault_namespace.fabric.path_fq

  policy = <<EOT
path "secret/*" {
  capabilities = ["read","list"]
}
EOT
}

resource "vault_identity_group" "fabric" {
  name             = "github"
  namespace        = vault_namespace.fabric.path_fq
  type             = "internal"
  policies         = ["default", vault_policy.fabric.name]
  member_group_ids = [vault_identity_group.admin.id]
}