# Provides user access at the team level.

# TODO: fix the next 2 paths to manage actual secrets
# Manage KV secrets engine
path "+/${store}/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

# Manage prod - but deny read
path "+/${store}/prod/*" {
  capabilities = ["create", "update", "patch", "delete", "list"]
}

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