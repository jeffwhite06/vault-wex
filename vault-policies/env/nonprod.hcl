# Manage KV secrets engine
path "${environment}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}