# Provides Security and Auditing access.

# Read leases
path "sys/leases/*" {
  capabilities = ["read", "list"]
}

# Read identities
path "identity/*" {
  capabilities = ["read", "list"]
}

# Read auth methods
path "auth/*" {
  capabilities = ["read", "list"]
}

# List auth methods
path "sys/auth" {
  capabilities = ["read"]
}

# List existing policies
path "sys/policies/acl" {
  capabilities = ["read","list"]
}

# Read policies
path "sys/policies/acl/*" {
  capabilities = ["read", "list"]
}

# List existing secret engines.
path "sys/mounts" {
  capabilities = ["read"]
}

# Read namespaces
path "sys/namespaces/*" {
  capabilities = ["read", "list"]
}