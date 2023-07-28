resource "vault_policy" "team" {
  count = var.policy == null ? 0 : 1

  name      = var.team
  namespace = var.team_path
  policy    = var.policy
}

resource "vault_identity_group" "team" {
  name             = var.team
  namespace        = var.team_path
  type             = "internal"
  policies         = length(vault_policy.team) > 0 ? ["default", vault_policy.team[0].name] :["default"]
  member_group_ids = [var.team_id]
}