# Provides user access at the team level.

# Manage shared secrets engine
path "${secret}/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

# Read secret engines
path "sys/mounts/*" {
  capabilities = ["read", "list"]
}

# List existing secret engines.
path "sys/mounts" {
  capabilities = ["read"]
}