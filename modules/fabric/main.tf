resource "vault_policy" "fabric" {
  count = var.policy == null ? 0 : 1

  name      = var.group
  namespace = var.fabric_path
  policy    = var.policy
}

resource "vault_identity_group" "fabric" {
  name             = var.group
  namespace        = var.fabric_path
  type             = "internal"
  policies         = length(vault_policy.fabric) > 0 ? ["default", vault_policy.fabric[0].name] : ["default"]
  member_group_ids = [var.team_id]
}