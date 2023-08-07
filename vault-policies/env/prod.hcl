# Manage KV secrets engine
path "${environment}/*" {
  capabilities = ["create", "update", "delete", "list"]
}