# Provides user access at the team level.

# Manage KV secrets engine
path "secret/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

# Manage prod - but deny read
path "secret/+/prod/*" {
  capabilities = ["create", "update", "patch", "delete", "list"]
}

# Read secret engines
path "sys/mounts/*" {
  capabilities = ["read", "list"]
}

# List existing secret engines.
path "sys/mounts" {
  capabilities = ["read"]
}