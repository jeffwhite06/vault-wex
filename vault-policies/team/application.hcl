# Provides access to Application Kubernetes and IAM roles.

# Read shared KV secrets
path "${secret}/*" {
  capabilities = ["read", "list"]
}

# Read entity environment secrets
path "{{identity.entity.metadata.environment}}/*" {
  capabilities = ["read", "list"] 
}