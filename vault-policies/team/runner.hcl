# Provides the Github Runner access to manage the team namespace.

# Manage identities
path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage auth methods broadly across Vault
path "auth/{{identity.entity.metadata.environment}}/*" {
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
path "{{identity.entity.metadata.environment}}/*" {
  capabilities = ["create", "update", "delete", "list"]
}

# Read KV secrets for environment
path "{{identity.entity.metadata.environment}}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage shared KV secrets
path "${secret}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage secret engines
path "sys/mounts/*" {
  capabilities = ["create", "update", "delete", "list", "sudo"]
}

# List existing secret engines.
path "sys/mounts" {
  capabilities = ["read"]
}