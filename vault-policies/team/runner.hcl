# Provides the Github Runner access to manage the team namespace.

# Manage identities
path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage auth methods broadly across Vault
path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*" {
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth" {
  capabilities = ["read"]
}

# Manage KV secrets engines
path "secret/*" {
  capabilities = ["create", "update", "delete", "list", "sudo"]
}

# Read KV secrets for environment
path "secret/prod/*" {
  capabilities = ["read"]
}

# Manage secret engines
path "sys/mounts/*" {
  capabilities = ["create", "update", "delete", "list", "sudo"]
}

# List existing secret engines.
path "sys/mounts" {
  capabilities = ["read"]
}